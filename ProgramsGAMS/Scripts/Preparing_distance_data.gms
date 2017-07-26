
*--- identifying municipalities and simu's that can constitute valid pairs

parameter valid_ibge_data;
valid_ibge_data(codmun_ibge_all)$ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') = 1;
scalar nvalid_ibge_data;
nvalid_ibge_data = card(valid_ibge_data);
display nvalid_ibge_data;

parameter valid_simu_area(simucont_id_all);
valid_simu_area(simucont_id_all) = 1;
scalar nvalid_simu_area;
nvalid_simu_area = card(valid_simu_area);
display nvalid_simu_area;

*--- weights for close municipalities and simulation units

scalar cut /10/;

parameter weights_proximity(simucont_id_all, codmun_ibge_all);

weights_proximity(simucont_id_all, codmun_ibge_all)$(valid_simu_area(simucont_id_all) and valid_ibge_data(codmun_ibge_all) and
                                               (IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun') +
                                               IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU') <= 0)) =
                                               cut + sqrt(power(CentroidesSIMU(simucont_id_all, 'X') - CentroidesMun(codmun_ibge_all, 'X'), 2) +
                                               power(CentroidesSIMU(simucont_id_all, 'Y') - CentroidesMun(codmun_ibge_all, 'Y'), 2));

weights_proximity(simucont_id_all, codmun_ibge_all)$(valid_simu_area(simucont_id_all) and valid_ibge_data(codmun_ibge_all) and
                                               (IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun') +
                                               IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU') > 0)) = 0;

*----- checking negative distances

parameter check_negative_weights(simucont_id_all, codmun_ibge_all);
check_negative_weights(simucont_id_all, codmun_ibge_all)$(weights_proximity(simucont_id_all, codmun_ibge_all) < 0) = weights_proximity(simucont_id_all, codmun_ibge_all);
display check_negative_weights;

scalar num_negative_weights;
num_negative_weights = card(check_negative_weights);
display num_negative_weights;

*----- distance statistics

parameter mean_weights_proximity;
mean_weights_proximity = sum((simucont_id_all, codmun_ibge_all)$(valid_simu_area(simucont_id_all) and valid_ibge_data(codmun_ibge_all)),
                                 weights_proximity(simucont_id_all, codmun_ibge_all)) / card(weights_proximity);

display mean_weights_proximity;

parameter valid_pairs(codmun_ibge_all, simucont_id_all);
valid_pairs(codmun_ibge_all, simucont_id_all)$(valid_ibge_data(codmun_ibge_all) and valid_simu_area(simucont_id_all) and
                                  (weights_proximity(simucont_id_all, codmun_ibge_all) < 15 or
                                  IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU') or
                                  IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun'))) = 1;

scalar number_valid_pairs;
number_valid_pairs = card(valid_pairs);
display number_valid_pairs;

scalar number_all_possible_pairs;
number_all_possible_pairs = card(weights_proximity);
display number_all_possible_pairs;

*------------- saving only the valid distances

file DADOS_DIST /'.\Resultados\Distances_simus_to_municipalities.gms'/;

DADOS_DIST.lw = 0;
DADOS_DIST.lj = 10;
DADOS_DIST.nw = 15;
DADOS_DIST.nd = 3;
DADOS_DIST.pw = 400;

PUT  DADOS_DIST;

PUT "PARAMETER VALID_DISTS(codmun_ibge_all, simucont_id_all) Distances for valid pairs to be considering on optimization problem" /;
PUT "/" /;
LOOP((codmun_ibge_all,simucont_id_all)
      $ valid_pairs(codmun_ibge_all, simucont_id_all),
                 PUT @4 , codmun_ibge_all.tl,'.',simucont_id_all.tl @50;
                 PUT weights_proximity(simucont_id_all, codmun_ibge_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

$ontext
$offtext

*---------------------------------------------------------------------*
*--------- the end                                      --------------*
*---------------------------------------------------------------------*
