#importing libraries
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error
from xgboost import XGBRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import GridSearchCV
import statsmodels.api as sm

file_path=r'C:\Users\DELL\quantum_vs_classical_fraud_cleaned.csv'
df=pd.read_csv(file_path)
df['transaction_value_usd'] = df['transaction_value_usd'].clip(lower=1)
df['latency_ms'] = df['latency_ms'].clip(lower=1)
df['log_transaction_value'] = np.log1p(df['transaction_value_usd'])
df['log_latency'] = np.log1p(df['latency_ms'])
X=df[['log_transaction_value','log_latency','security_level_score']]
Y=df['expected_profit_usd']
#training

from sklearn.model_selection import train_test_split


X_train, X_test, Y_train, Y_test = train_test_split(
    X, Y, test_size=0.2, random_state=42
)

#linear model
lm= LinearRegression()
lm.fit(X_train,Y_train)
Y_pred= lm.predict(X_test)
from sklearn.metrics import r2_score

r2 = r2_score(Y_test, Y_pred)
print("R² of linear regression:", r2)
from sklearn.metrics import mean_squared_error
import numpy as np

rmse = np.sqrt(mean_squared_error(Y_test, Y_pred))
print("RMSE of linear regression:", rmse)

MAE= mean_absolute_error(Y_test, Y_pred)
print("MAE of Linear regression: " , MAE)
coeff_df = pd.DataFrame({
    'Feature': X.columns,
    'Coefficient': lm.coef_
})

print(coeff_df)

#testing random forest
rf = RandomForestRegressor(random_state=42)

param_grid = {
    'n_estimators': [100, 200],
    'max_depth': [None, 10, 20],
    'min_samples_split': [2, 5],
    'min_samples_leaf': [1, 2]
}

grid_rf = GridSearchCV(
    rf,
    param_grid,
    cv=5,
    scoring='r2',
    n_jobs=-1,
    verbose=2
)

grid_rf.fit(X_train, Y_train)

best_rf = grid_rf.best_estimator_
print(best_rf)
rf_importance = pd.DataFrame({
    'Feature': X.columns,
    'Importance': best_rf.feature_importances_
}).sort_values(by='Importance', ascending=False)

print(rf_importance)

#use the best parameters of rf
rf=RandomForestRegressor(min_samples_leaf=2, n_estimators=200, random_state=42)
rf.fit(X_train,Y_train)
Y_pred_rf=rf.predict(X_test)
r2 = r2_score(Y_test, Y_pred_rf)
print("R2 score of Random Forest:", r2)

# Mean Absolute Error
mae = mean_absolute_error(Y_test, Y_pred_rf)
print("MAE score of Random Forest:", mae)

# Root Mean Squared Error
rmse = np.sqrt(mean_squared_error(Y_test, Y_pred_rf))
print("RMSE of Random Forest:", rmse)

#comparing to XGBoost
xgb = XGBRegressor(
    n_estimators=500,
    max_depth=5,
    learning_rate=0.05,
    subsample=0.8,
    colsample_bytree=0.8,
    random_state=42
)

# Fit
xgb.fit(X_train, Y_train, eval_set=[(X_test, Y_test)], verbose=2)

# Predict
Y_pred_xgb = xgb.predict(X_test)

# Evaluate
r2 = r2_score(Y_test, Y_pred_xgb)
mae = mean_absolute_error(Y_test, Y_pred_xgb)
rmse = np.sqrt(mean_squared_error(Y_test, Y_pred_xgb))

print("XGBoost R²:", r2)
print("XGBoost MAE:", mae)
print("XGBoost RMSE:", rmse)