# Abalone Age Prediction
Comparing CART Regression and Random Forest Models

## Project Overview
This project predicts abalone age (measured by shell ring count) using machine learning models implemented in R. Since age strongly influences market value, accurate prediction is important for fisheries and aquaculture.

Two models were developed and compared: CART Regression Tree and Random Forest.

The dataset was obtained from the UCI Machine Learning Repository and contains 4,177 observations with eight physical predictors (e.g., length, weight, height) and one target variable (Rings).

## Dataset
* Source: UCI Machine Learning Repository
* Observations: 4,177
* Predictors: Sex, Length, Diameter, Height, Whole_weight, Shucked_weight, Viscera_weight, Shell_weight
* Target: Rings (Age ≈ Rings + 1.5 years)

The dataset contains some extreme values. Most outliers were retained due to limited biological justification for removal.

## Methods
* Data cleaning and exploratory analysis (boxplots, distribution analysis, correlation matrix)
* Train/test split and 10-fold cross-validation
* Hyperparameter tuning:
* CART (complexity parameter cp)
* Random Forest (mtry, number of trees, node size)
* Evaluation metrics:
    * RMSE
    * MAE
    * R²

All models were implemented in R.

## Results

| Model                |  RMSE |  MAE |  R²  |
| -------------        | ----- | ---- | ---  |
| Regression Tree      | 2.18  | 1.58 | 0.52 |
| Cross-Validated CART | 2.32  | 1.65 | 0.46 |
| Random Forest        | 1.98  | 1.43 | 0.59 |

<img width="1257" height="501" alt="image" src="https://github.com/user-attachments/assets/6a822b29-728a-4838-ab83-bac550cc4b08" />

Comparison between Cross-Validated Regression Tree (Left) and Random Forest Model (Right): Actual vs Predicted Rings

## Conclusion

Random Forest outperformed CART in predicting abalone age, reducing prediction error while explaining approximately 60% of the variance in ring counts.

However, model performance is influenced by:

* Extreme outliers
* Imbalanced age distribution
* Lack of additional environmental variables (e.g., location, climate)

Future improvements could include data balancing techniques and testing more advanced ensemble methods.




