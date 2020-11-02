# VDB-SE Matlab implementation

## Marco Mussi, Luigi Pellegrino, Marcello Restelli, Francesco Trovò

### Politecnico di Milano and Ricerca Sistema Energetico


Implementation of VDB-SE proposed on Engineering Applications of Artificial Intelligence.

This algorithm requires Matlab Optimization Toolbox.

The scripts to test the VDB-SE are:

> main_vdbse_singlecell

> main_vdbse_clustercell

The first shows the experiments on synthetic data retrived from a power profile on a single cell.

Inside the script there is a boolean vector and a boolean variable to add biases at the data.

The second shows the analisys on real data retrieved from a self-consuption test on a cluster of cells.


A further script allows to estimate results provided by CC over the same data (open scripts to edit biases coherently with the others experiments):

> main_cc_singlecell


While the following script allows to load data (and add biases to data, see the script for futher info) to see how Codeca et Al. model-based (MB) algorithm performs:

> load_mb_data

Once the data are loaded, MB can be tested through Simulink model:

> main_mb.mdl