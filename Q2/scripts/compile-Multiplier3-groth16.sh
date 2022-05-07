#!/bin/bash

# [assignment] create your own bash script to compile Multipler3.circom modeling after compile-HelloWorld.sh below

cd contracts/circuits

mkdir Multiplier3

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Multiplier3.circom..."

# compile circuit

circom Multiplier3.circom --r1cs --wasm --sym -o Multiplier3
snarkjs r1cs info Multiplier3/Multiplier3.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup Multiplier3/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3/Multiplier3_0000.zkey
snarkjs zkey contribute Multiplier3/Multiplier3_0000.zkey Multiplier3/Multiplier3_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey Multiplier3/Multiplier3_final.zkey Multiplier3/verification_key.json

#export r1cs to json
#snarkjs r1cs export json Multiplier3/Multiplier3.r1cs Multiplier3/Multiplier3.r1cs.json
#cat Multiplier3/Multiplier3.r1cs.json

#calculate witness
# cat <<EOT > Multiplier3/input.json
# {"a": 3, "b": 5, "c": 7 }
# EOT

#Create witness file
# node Multiplier3/Multiplier3_js/generate_witness.js Multiplier3/Multiplier3_js/Multiplier3.wasm Multiplier3/input.json Multiplier3/witness.wtns

#create the proof
# snarkjs groth16 prove Multiplier3/Multiplier3_final.zkey Multiplier3/witness.wtns Multiplier3/proof.json Multiplier3/public.json

#verify the proof
# snarkjs groth16 verify Multiplier3/verification_key.json Multiplier3/public.json Multiplier3/proof.json


# generate solidity contract
snarkjs zkey export solidityverifier Multiplier3/Multiplier3_final.zkey ../Multiplier3Verifier.sol

cd ../..