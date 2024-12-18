# %%
import datetime
import pandas as pd
import sqlalchemy

from sklearn import model_selection
from sklearn import ensemble
from sklearn import pipeline
from sklearn import metrics

from feature_engine import encoding

import mlflow

# %%
# Conexão com o BD
engine = sqlalchemy.create_engine('sqlite:///../../data/feature_store.db')


#Query
with open('abt.sql', 'r') as open_file:
    query = open_file.read()

#Processa e Busca os dados
df = pd.read_sql(query, engine)
df.head()

  # %%
# Separação entre dados de validação (OOT = Out Of Time) e treinamento
df_oot = df[df['dtRef']==df['dtRef'].max()]
df_train = df[df['dtRef']<df['dtRef'].max()]
# %%

target = 'flChurn'
features = df_train.columns[3:].tolist()
# %%
X_train, X_test, y_train, y_test = model_selection.train_test_split(df_train[features],
                                                                    df_train[target],
                                                                    random_state=42,
                                                                    train_size=0.8,
                                                                    stratify=df_train[target])


print("Taxa de resposta na base de Treino: ", y_train.mean())
print("Taxa de resposta na base de Teste: ", y_test.mean())
# %%

cat_features = X_train.dtypes[X_train.dtypes == 'object'].index.tolist()
num_features = list(set(features) - set(cat_features))
#cat_features, num_features
# %%
X_train[cat_features].describe()
X_train[cat_features].drop_duplicates()
# %%
X_train[num_features].describe().T
X_train[num_features].isna().sum().max()

# %% 

mlflow.set_tracking_uri(uri="http://127.0.0.1:8080")
mlflow.set_experiment(experiment_id=794087697093409055)
mlflow.autolog()

# %%

def report_metrics(y_true, y_proba, base, cohort=0.5):

    y_pred = (y_proba[:,1]>cohort).astype(int)

    acc = metrics.accuracy_score(y_true, y_pred)
    auc = metrics.roc_auc_score(y_true, y_proba[:,1])
    precision = metrics.precision_score(y_true, y_pred)
    recall = metrics.recall_score(y_true, y_pred)

    res = {
        f' {base} Acurárica': acc,
        f' {base} Curva Roc': auc,
        f" {base} Precisão": precision,
        f" {base} Recall": recall,
        }

    return res

with mlflow.start_run():

    onehot = encoding.OneHotEncoder(variables=cat_features,
                                    drop_last=True)

##    model = ensemble.RandomForestClassifier(random_state=42,
#                                            min_samples_leaf=25)
#    model = ensemble.AdaBoostClassifier(random_state=42)
    model = ensemble.GradientBoostingClassifier(random_state=42)
#    params = {"min_samples_leaf": [10, 25, 50, 75],
#            "n_estimators": [100, 200, 500],
#            "criterion": ['gini'],
#            "max_depth": [5,8,10,12,15]
#            }
#    params = {"learning_rate": [0.01, 0.1, 0.2, 0.5, 0.75, 0.9, 0.99],
#            "n_estimators": [100, 200, 500]}
    params = {"learning_rate": [0.01, 0.1, 0.2, 0.5, 0.75, 0.9, 0.99],
            "n_estimators": [100, 200, 500],
            "subsample": [0.1, 0.5, 0.9],
            "min_samples_leaf": [5, 10, 25, 50, 100],}

    grid = model_selection.GridSearchCV(model, 
                                        param_grid=params,
                                        cv=3,
                                        scoring='roc_auc',
                                        n_jobs=-2,
                                        verbose=3)

    model_pipeline = pipeline.Pipeline([
    ('One Hot Encode', onehot),
    ('Modelo', grid)
    ])
    #Ajuste do Modelo
    model_pipeline.fit(X_train, y_train)

    #Aplicação do modelo em diferentes bases de dados
    y_train_proba = model_pipeline.predict_proba(X_train)
    y_test_proba = model_pipeline.predict_proba(X_test)
    y_oot_proba = model_pipeline.predict_proba(df_oot[features])

    report = {}
    report.update(report_metrics(y_train, y_train_proba, 'treino'))
    report.update(report_metrics(y_test, y_test_proba, 'teste'))
    report.update(report_metrics(df_oot[target], y_oot_proba, "oot"))
    report
    mlflow.log_metrics(report)

# %%
