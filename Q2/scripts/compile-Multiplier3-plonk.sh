#!/bin/bash

# [assignment] create your own bash script to compile Multipler3.circom using PLONK below

cd contracts/circuits

mkdir Multiplier3-plonk

echo "Compiling Multiplier3.circom..."

# compile circuit

circom Multiplier3.circom --r1cs --wasm --sym -o Multiplier3-plonk
snarkjs r1cs info Multiplier3-plonk/Multiplier3.r1cs

# Start a new zkey and make a contribution

snarkjs plonk setup Multiplier3-plonk/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3-plonk/Multiplier3_final.zkey
#snarkjs zkey contribute Multiplier3-plonk/circuit_0000.zkey Multiplier3-plonk/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey Multiplier3-plonk/Multiplier3_final.zkey Multiplier3-plonk/verification_key.json

# generate solidity contract
#snarkjs zkey export solidityverifier Multiplier3-plonk/Multiplier3_final.zkey ../Multiplier3Verifier.sol

cd ../..