#!/bin/bash

cd contracts/circuit

mkdir LessThan10

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling LessThan10.circom..."

# compile circuit
circom LessThan10.circom --r1cs --wasm --sym -o LessThan10
snarkjs r1cs info LessThan10/LessThan10.r1cs

# print constraints
snarkjs r1cs print LessThan10/LessThan10.r1cs LessThan10/LessThan10.sym

#export r1cs to json
snarkjs r1cs export json LessThan10/LessThan10.r1cs LessThan10/LessThan10.r1cs.json
cat LessThan10/LessThan10.r1cs.json

# Start a new zkey and make a contribution

snarkjs groth16 setup LessThan10/LessThan10.r1cs powersOfTau28_hez_final_10.ptau LessThan10/circuit_0000.zkey
snarkjs zkey contribute LessThan10/circuit_0000.zkey LessThan10/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey LessThan10/circuit_final.zkey LessThan10/verification_key.json

#calculate witness
cat <<EOT > LessThan10/input.json
{"in": 3 }
EOT

#Create witness file
node LessThan10/LessThan10_js/generate_witness.js LessThan10/LessThan10_js/LessThan10.wasm LessThan10/input.json LessThan10/witness.wtns

#create the proof
snarkjs groth16 prove LessThan10/circuit_final.zkey LessThan10/witness.wtns LessThan10/proof.json LessThan10/public.json

#verify the proof
snarkjs groth16 verify LessThan10/verification_key.json LessThan10/public.json LessThan10/proof.json

# generate solidity contract
snarkjs zkey export solidityverifier LessThan10/circuit_final.zkey ../LessThan10Verifier.sol

cd ../..