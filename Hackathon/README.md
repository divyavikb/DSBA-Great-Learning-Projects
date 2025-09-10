# Shinkansen Travel Experience — Short README

**Predict passenger satisfaction (Overall_Experience)** for Shinkansen (bullet train) journeys by combining travel logs and post-trip survey responses.

**Objective**
- Predict whether a passenger is satisfied (`Overall_Experience` = 1) or not (0).
- Identify the most influential features driving satisfaction.

**Dataset**
- Two paired datasets: **Traveldata** (train/test) and **Surveydata** (train/test).
- Training data includes the `Overall_Experience` label. Test set requires submission of predictions (CSV with `ID,Overall_Experience` — 35,602 rows + header).

**Evaluation**
- Metric: **Accuracy** (fraction of correct predictions).


**Approach highlights**
- Clean & merge travel + survey data, handle missing values.
- Feature engineering: delay flags, aggregated survey scores, interaction terms.
- Models: Logistic Regression baseline → Bagging and Boosting Algorithms for top performance.

**Outcome**
- Reproducible pipeline for data → features → model → submission, accompanied by EDA and model explainability artifacts.

