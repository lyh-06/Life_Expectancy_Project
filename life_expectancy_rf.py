import pandas as pd
import sqlalchemy
from sqlalchemy import create_engine

engine = create_engine("sqlite:////Users/yuiheilo/mortality.db")

df = pd.read_sql("SELECT * FROM mortality_lifeexp", engine) # Load table into pd dataframe
print(df.head())

# Sanity check
print(df.head())
print(df.shape)
print(df.isna().sum().sort_values(ascending=False)) # Count missing value

X = df.drop(columns=["life_expectancy", "Country"]) # Death causes as features
y = df["life_expectancy"] # Life expectancy (target value)

# Baseline model

from sklearn.model_selection import cross_val_score
from sklearn.linear_model import LinearRegression

lr = LinearRegression()
cv_r2 = cross_val_score(lr, X, y, cv=5, scoring="r2")

print("Baseline R^2 Score:", cv_r2.mean())

# Random Forest 

from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.ensemble import RandomForestRegressor

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

rf = RandomForestRegressor(n_estimators=500, random_state=42)
rf.fit(X_train, y_train)

pred = rf.predict(X_test)
print("Mean Absolute Error:", mean_absolute_error(y_test, pred))
print("R^2 Score:", r2_score(y_test, pred))

# K-means clustering
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

km = KMeans(n_clusters=5, random_state=42, n_init=20)
df["cluster"] = km.fit_predict(X_scaled)

df.groupby("cluster").mean(numeric_only=True).sort_values("life_expectancy")

# Model performance visualization: actual vs. predicted life expectancy
import matplotlib.pyplot as plt
import seaborn as sns

plt.figure(figsize=(8, 6))
plt.scatter(y_test, pred, alpha=0.6)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
plt.xlabel("Actual Life Expectancy")
plt.ylabel("Predicted Life Expectancy")
plt.title("Actual vs Predicted Life Expectancy")
plt.tight_layout()
plt.show()

# Feature importance visualization: Top Mortality Causes Affecting Life Expectancy

# Extract and organize feature imporances
importances = pd.DataFrame({
    "feature": X.columns,
    "importance": rf.feature_importances_ # importance scores from trained rf model
}).sort_values(by='importance', ascending=False).head(15)

# Create bar chart
plt.figure(figsize=(10, 8))
plt.barh(importances["feature"], importances["importance"])
plt.xlabel("Importance Score")
plt.title("Top 15 Mortality Causes Affecting Life Expectancy")
plt.gca().invert_yaxis() # Invert y-axis to have highest importance at the top
plt.tight_layout()
plt.show()

