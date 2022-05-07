const { expect } = require("chai");
const { ethers } = require("hardhat");
const fs = require("fs");
const { groth16, plonk } = require("snarkjs");

function unstringifyBigInts(o) {
    if ((typeof(o) == "string") && (/^[0-9]+$/.test(o) ))  {
        return BigInt(o);
    } else if ((typeof(o) == "string") && (/^0x[0-9a-fA-F]+$/.test(o) ))  {
        return BigInt(o);
    } else if (Array.isArray(o)) {
        return o.map(unstringifyBigInts);
    } else if (typeof o == "object") {
        if (o===null) return null;
        const res = {};
        const keys = Object.keys(o);
        keys.forEach( (k) => {
            res[k] = unstringifyBigInts(o[k]);
        });
        return res;
    } else {
        return o;
    }
}

describe("HelloWorld", function () {
    let Verifier;
    let verifier;

    beforeEach(async function () {
        Verifier = await ethers.getContractFactory("HelloWorldVerifier");
        verifier = await Verifier.deploy();
        await verifier.deployed();
    });

    it("Should return true for correct proof", async function () {
        //[assignment] Add comments to explain what each line is doing //https://github.com/iden3/snarkjs#7-prepare-phase-2
        //create the proof and calculate the witness in the same command
        const { proof, publicSignals } = await groth16.fullProve({"a":"1","b":"2"}, "contracts/circuits/HelloWorld/HelloWorld_js/HelloWorld.wasm","contracts/circuits/HelloWorld/circuit_final.zkey");

        console.log('1x2 =',publicSignals[0]);

        const editedPublicSignals = unstringifyBigInts(publicSignals);
        const editedProof = unstringifyBigInts(proof);
        const calldata = await groth16.exportSolidityCallData(editedProof, editedPublicSignals);
    
        const argv = calldata.replace(/["[\]\s]/g, "").split(',').map(x => BigInt(x).toString());
    
        const a = [argv[0], argv[1]];
        const b = [[argv[2], argv[3]], [argv[4], argv[5]]];
        const c = [argv[6], argv[7]];
        const Input = argv.slice(8);

        expect(await verifier.verifyProof(a, b, c, Input)).to.be.true;
    });
    it("Should return false for invalid proof", async function () {
        let a = [0, 0];
        let b = [[0, 0], [0, 0]];
        let c = [0, 0];
        let d = [0]
        expect(await verifier.verifyProof(a, b, c, d)).to.be.false;
    });
});


describe("Multiplier3 with Groth16", function () {

    let Multiplier3;
    let multiplier3;

    beforeEach(async function () {
        //[assignment] insert your script here
        Multiplier3 = await ethers.getContractFactory("Multiplier3Verifier");
        multiplier3 = await Multiplier3.deploy();
        await multiplier3.deployed();
    });

    it("Should return true for correct proof", async function () {
        //[assignment] insert your script here
        //create the proof and calculate the witness in the same command
        const { proof, publicSignals } = await groth16.fullProve({"a":"3","b":"5","c":"7"}, "contracts/circuits/Multiplier3/Multiplier3_js/Multiplier3.wasm","contracts/circuits/Multiplier3/Multiplier3_final.zkey");

        console.log('3x5X7 =',publicSignals[0]);
    });
    it("Should return false for invalid proof", async function () {
        //[assignment] insert your script here
    });
});


describe("Multiplier3 with PLONK", function () {
    let Multiplier3;
    let multiplier3;

    beforeEach(async function () {
        //[assignment] insert your script here
        Multiplier3 = await ethers.getContractFactory("Multiplier3Verifier");
        multiplier3 = await Multiplier3.deploy();
        await multiplier3.deployed();
    });

    it("Should return true for correct proof", async function () {
        //[assignment] insert your script here
        //create the proof and calculate the witness in the same command
        const { proof, publicSignals } = await plonk.fullProve({"a":"7","b":"1","c":"3"}, "contracts/circuits/Multiplier3-plonk/Multiplier3_js/Multiplier3.wasm","contracts/circuits/Multiplier3-plonk/Multiplier3_final.zkey");

        console.log('7x1X3 =',publicSignals[0]);
    });
    it("Should return false for invalid proof", async function () {
        //[assignment] insert your script here
    });
});