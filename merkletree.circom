pragma circom 2.0.0;

include "mimcsponge.circom";
/*This circuit template checks that root is the root of a merkle tree with leaves from 1 to n */

template MerkleTree (n) {  

   signal input leaves[n]; 
   signal output root;  
   var N = n*2-1;
   signal hashes[N];
   component components[N];

    var j = 0;
    for(var i = 0; i < N; i++) {
        if(i < n) {
            // apply hash to leaves
            components[i] = MiMCSponge(1, 220, 1);
            components[i].k <== i;
            components[i].ins[0] <== leaves[i];
        } else {
            // construct the merkle tree from bottom to top
            components[i] = MiMCSponge(2, 220, 1);
            components[i].k <== i;
            components[i].ins[0] <== hashes[j];
            components[i].ins[1] <== hashes[j+1];
            j+=2;
        }
        hashes[i] <== components[i].outs[0];
    }

    // return hash of root
    root <== hashes[N-1];
} 

component main {public [leaves]} = MerkleTree(4);
