#!/bin/bash

MATRIX_SIZE=16
THREADS_LIST=(1 2 4 8 16)
GEM5_EXEC="$GEM5/build/ARM/gem5.fast"
CONFIG_FILE="$GEM5/configs/example/se.py"
EXECUTABLE="test_omp"

for NTHREADS in "${THREADS_LIST[@]}"; do
    OUTPUT_DIR="m5out_m${MATRIX_SIZE}_t${NTHREADS}"
    
    # Exécuter gem5 et attendre la fin de l'exécution
    echo "Exécution de la simulation avec une taille de matrice de $MATRIX_SIZE et $NTHREADS threads..."
    $GEM5_EXEC $CONFIG_FILE -n 16 -c $EXECUTABLE -o "$NTHREADS $MATRIX_SIZE" --cpu-type=arm_detailed --caches
    
    # Attendre la génération du fichier stats.txt
    while [ ! -s "m5out/stats.txt" ]; do
        echo "En attente de l'écriture du fichier stats.txt..."
        sleep 2  # Vérifier toutes les 2 secondes
    done

    # Déplacer le répertoire m5out
    mv m5out "$OUTPUT_DIR"
    echo "Simulation terminée pour NTHREADS=$NTHREADS, résultats enregistrés dans $OUTPUT_DIR"
done

echo "Toutes les simulations sont terminées !"
