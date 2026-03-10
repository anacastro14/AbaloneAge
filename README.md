# Abalone Age Prediction with Machine Learning

## Project Overview
This project focuses on predicting the age of abalones by the number of rings in their shells using machine learning techniques. The age of abalones is a crucial factor in determining their market value, making accurate predictions valuable for the fishing and aquaculture industries. This repository contains the R code and documentation for developing and comparing two regression models: a Classification and Regression Tree (CART) and a Random Forest.

## Table of Contents
*   [Project Overview](#project-overview)
*   [Dataset](#dataset)
*   [Methods](#methods)
*   [Results](#results)
    *   [Actual vs. Predicted Rings](#actual-vs-predicted-rings)
*   [Conclusion](#conclusion)
*   [Installation](#installation)
*   [Usage](#usage)
*   [Contributing](#contributing)
*   [License](#license)
  
## Dataset
The dataset used in this project was obtained from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/1/abalone).

* Source: UCI Machine Learning Repository
* Observations: 4,177
* Predictors: Sex, Length, Diameter, Height, Whole_weight, Shucked_weight, Viscera_weight, Shell_weight
* Target: Rings (Age in years can be approximated by adding 1.5 to the number of rings)

The dataset contains some extreme values. After careful consideration, most outliers were retained due to a lack of clear biological justification for their removal.

## Methods
The project was implemented in R and followed these steps:

1. Data Cleaning and Exploratory Data Analysis (EDA): The data was cleaned, and an EDA was performed using boxplots, distribution analysis, and a correlation matrix to understand the relationships between variables.

2. Data Splitting: The dataset was split into a training set (80%) and a testing set (20%).

3. Cross-Validation: 10-fold cross-validation was used during model training to ensure the robustness of the models.

4. **Hyperparameter Tuning:** 

   *  CART: The complexity parameter (cp) was tuned to find the optimal tree depth.

   *  Random Forest: The mtry, number of trees, and node size were tuned to optimize the model's performance.

5. **Evaluation Metrics:** The models were evaluated using the following metrics:

   *  Root Mean Squared Error (RMSE)

   *  Mean Absolute Error (MAE)

   *  R-squared (R²)

## Results

| Model                |  RMSE |  MAE |  R²  |
| -------------        | ----- | ---- | ---  |
| Regression Tree      | 2.18  | 1.58 | 0.52 |
| Cross-Validated CART | 2.32  | 1.65 | 0.46 |
| Random Forest        | 1.98  | 1.43 | 0.59 |

## Actual vs. Predicted Rings
The scatter plots below visually compare the performance of the two models. The Random Forest model's predictions are more tightly clustered around the diagonal line, indicating a stronger correlation between actual and predicted values and confirming its lower error rates.

<img width="1257" height="501" alt="image" src="https://github.com/user-attachments/assets/6a822b29-728a-4838-ab83-bac550cc4b08" />

## Conclusion

The Random Forest model is the better choice for predicting abalone age in this project. However, the model's performance is influenced by:

* Extreme outliers in the dataset.
* An imbalanced age distribution.
* The lack of additional environmental variables such as location and climate data.

Future work could explore data balancing techniques (e.g., SMOTE for regression) and more advanced ensemble methods like Gradient Boosting to potentially improve the prediction accuracy.

## Installation

To run this project, you need to have R and RStudio installed. You can install the necessary R packages by running the following command in your R console:

```R
install.packages(c("tidyverse", "caret", "rpart", "rpart.plot", "randomForest", "Metrics"))
```
## Usage
To get a local copy up and running, follow these simple steps.

1. Clone the repository:

```Bash
git clone https://github.com/anacastro14/abalone-age-prediction.git
```
2. Navigate to the project directory:

```Bash
cd abalone-age-prediction
```
3. Open the R script (abalone_prediction.R) in RStudio.
4. Run the script from top to bottom to reproduce the analysis and results.

## Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1. Fork the Project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

## License
Distributed under the MIT License. See LICENSE file for more information.
