# %%

import pandas as pd 
import sqlalchemy
from sqlalchemy import exc

import mlflow
import mlflow.sklearn

import json


print("Iniciando Script de modelos!")

print("Carregando modelos salvos.")
#model_series = pd.read_pickle("../../models/rf_model_fim.pkl")
#model_series
mlflow.set_tracking_uri("http://127.0.0.1:8080")
model = mlflow.sklearn.load_model("models:/Churn-Raphael/production")
model
# %%

print("Carregando as features do modelo...")
model_info = mlflow.models.get_model_info("models:/Churn-Raphael/production")
features = [i["name"] for i in json.loads(model_info.signature_dict['inputs'])]
features

# %%

engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")

print("Carregando base de dados")
with open("etl.sql", "r") as open_file:
    query = open_file.read()

df = pd.read_sql(query, engine)
# %%

print("Realizando predições")
pred = model.predict_proba(df[features])
proba_churn = pred[:,1]

print("Persistindo dados")
df_predict = df[['dtRef', "idCustomer"]].copy()
df_predict['probaChurn'] = proba_churn.copy()

df_predict = (df_predict.sort_values("probaChurn", ascending=False)
           .reset_index(drop=True)
)

with engine.connect() as con:
    state = f"DELETE FROM tb_churn WHERE dtRef = '{df_predict['dtRef'].min()}';"
    try:
        state = sqlalchemy.text(state)
        con.execute(state)
        con.commit()
    except exc.OperationalError as err:
        print("Tabela ainda não existe...")

df_predict.to_sql("tb_churn", engine, if_exists='append', index=False)
print("Sucesso!")
df_predict
# %%
