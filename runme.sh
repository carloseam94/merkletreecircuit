#!/bin/bash 

# compile circuit
circom merkletree.circom --r1cs --wasm --sym --c

# generate witness using c++ (because is faster for large circuits)
cd ./merkletree_cpp
make
cp ../input.json ./input.json
./merkletree input.json witness.wtns
mv ./witness.wtns ../witness.wtns
cd ..

# Generating a trusted setup to use the Groth16 zk-SNARK protocol

# Part 1: the powers of tau (independent of the circuit)
# start a new powersoftau ceremony
snarkjs powersoftau new bn128 13 pot13_0000.ptau -v
# contribute to the ceremony
snarkjs powersoftau contribute pot13_0000.ptau pot13_0001.ptau --name="First contribution" -v

# Part 2: (circuit dependent)
# start the generation of this phase
snarkjs powersoftau prepare phase2 pot13_0001.ptau pot13_final.ptau -v
# generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup merkletree.r1cs pot13_final.ptau merkletree_0000.zkey
# Contribute to the phase 2 of the ceremony
snarkjs zkey contribute merkletree_0000.zkey merkletree_0001.zkey --name="1st Contributor Name" -v
# Export the verification key
snarkjs zkey export verificationkey merkletree_0001.zkey verification_key.json

# Generating a proof
# generate a zk-proof associated to the circuit and the witness
snarkjs groth16 prove merkletree_0001.zkey witness.wtns proof.json public.json

# Verifying a proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Optional
# generate a Solidity verifier that allows verifying proofs on Ethereum blockchain
snarkjs zkey export solidityverifier merkletree_0001.zkey verifier.sol
# generate the parameters of the call (testing purposes)
snarkjs generatecall

