#!/bin/bash

# Taille de la matrice (modifiable)
MATRIX_SIZE=16  # Vous pouvez définir une taille différente

# Chemin de l'exécutable gem5
GEM5_EXEC="$GEM5/build/ARM/gem5.fast"

# Chemin du fichier de configuration
CONFIG_FILE="$GEM5/configs/example/se.py"

# Programme exécutable à exécuter
EXECUTABLE="test_omp"

# Liste du nombre de threads (commence à 1, croissance exponentielle)
THREADS_LIST=(1 2 4 8 16)

# Exécuter la simulation
for NTHREADS in "${THREADS_LIST[@]}"; do
    # Créer un dossier de sortie avec la taille de la matrice et le nombre de threads
    OUTPUT_DIR="m5out_m${MATRIX_SIZE}_t${NTHREADS}"
    
    # Exécuter la simulation gem5
    echo "Exécution de la simulation avec une matrice de taille $MATRIX_SIZE et $NTHREADS threads..."
    $GEM5_EXEC $CONFIG_FILE -n 16 -c $EXECUTABLE -o "$NTHREADS $MATRIX_SIZE" --cpu-type=detailed --caches
    
    # Déplacer la sortie vers le dossier correspondant
    mv m5out "$OUTPUT_DIR"

    echo "Simulation terminée pour NTHREADS=$NTHREADS, résultats enregistrés dans $OUTPUT_DIR"
done

echo "Toutes les simulations sont terminées !"
