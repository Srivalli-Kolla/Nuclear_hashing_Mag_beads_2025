# Load necessary libraries
library(celda)
library(scater)
library(singleCellTK) # To import raw data in form "outs/raw_feature_bc_matrix/"

# Import data
sce.raw <- importCellRanger(
  sampleDirs = "./data", 
  dataType = "filtered"
)

# Data processing

## Run decontX for ambient RNA contamination correction
decontx_sce <- decontX(sce.raw)

# Plotting

## Contamination plotting
plotDecontXContamination(decontx_sce)

## Cluster plotting
umap <- reducedDim(decontx_sce, "decontX_UMAP")
plotDimReduceCluster(x = decontx_sce$decontX_clusters,
                     dim1 = umap[, 1], dim2 = umap[, 2])
## Expression markers
norm_sce <- logNormCounts(decontx_sce)
rownames(norm_sce) <- rowData(norm_sce)$feature_name   # Replace Ensembl IDs with feature names as row names
plotDimReduceFeature(logcounts(norm_sce),
                     dim1 = umap[, 1],
                     dim2 = umap[, 2],
                     features = c('Ttn','Dcn','Dmd'))
### Expression markers - Barplots
markers <- list("Cardiomyocytes" = c("Ttn"), "Fibroblasts" = c("Dcn"))
plotDecontXMarkerPercentage(norm_sce,
                            markers = markers,
                            assayName = "counts") # Percentage of markers in clusters in raw
plotDecontXMarkerPercentage(norm_sce,
                            markers = markers,
                            assayName = "decontXcounts") # Percentage of markers in clusters in decontx data
plotDecontXMarkerPercentage(norm_sce,
                            markers = markers,
                            assayName = c("counts", "decontXcounts")) # Percentage of markers comparision in clusters
### Expression markers - Violin plots
plotDecontXMarkerExpression(norm_sce,
                            markers = markers,
                            ncol = 3)


hist(decontx_sce$decontX_contamination)
summary(decontx_sce$decontX_contamination)
