## sas-image-deforestification
# Satellite Image Classification for detecting Deforestation in Romania using SAS Viya, the Amazon Dataset and Sentinel 2

[Train Dataset](https://drive.google.com/file/d/199zqlL_K3ZQWuyrPxdoB_KsKi7-pIG1j/view?usp=share_link) -- This is the modified dataset that we created for our image classification problem. The dataset contains the training images from [Planet: Understanding the Amazon from Space](https://www.kaggle.com/competitions/planet-understanding-the-amazon-from-space/data) on Kaggle, but the classes are now binary: deforestification, non_deforestification

[Validation Dataset](https://scihub.copernicus.eu/dhus/#/home) -- The second dataset, serving as the validation set, was collected from the Copernicus Sentinel-2 mission which provides information about the changes in land cover and world’s forests. We used product type S2MSI2A which has atmospheric correction applied and collected four tiles (T34TFR, T35TLL, T35TLN, T34TFS) marking four regions of interest from Romanian Carpathians: Eastern, Southern and Western, which were identified as having massive deforestation. Only the bands B04, B03, B02 equivalent to RGB were extracted.
