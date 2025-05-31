"use client";

import { MOCK_TOKEN_ADDRESS, MOCK_USDC_ABI } from "@/abi/mock-usdc-abi";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useState } from "react";
import { formatUnits, parseUnits } from "viem";
import { useAccount, useReadContracts, useWriteContract } from "wagmi";

export default function Home() {
  const { address, isConnected } = useAccount();

  const { data, isLoading } = useReadContracts({
    contracts: [
      {
        abi: MOCK_USDC_ABI,
        address: MOCK_TOKEN_ADDRESS,
        functionName: "name",
      },
      {
        abi: MOCK_USDC_ABI,
        address: MOCK_TOKEN_ADDRESS,
        functionName: "symbol",
      },
      {
        abi: MOCK_USDC_ABI,
        address: MOCK_TOKEN_ADDRESS,
        functionName: "decimals",
      },
      {
        abi: MOCK_USDC_ABI,
        address: MOCK_TOKEN_ADDRESS,
        functionName: "balanceOf",
        args: [address as `0x${string}`],
      },
    ],
  });

  const name = data?.[0].result;
  const symbol = data?.[1].result;
  const decimals = data?.[2].result;
  const balanceUser = data?.[3].result;

  const BalanceUser = () => {
    if (!isConnected) {
      return <h1>Please connect your account!</h1>;
    }

    if (isLoading) {
      return <p>Loading....</p>;
    }

    return (
      <p>
        balanceUser : {formatUnits(balanceUser || BigInt(0), decimals || 18)}
      </p>
    );
  };

  const MintComponent = () => {
    const [userAddress, setUserAddress] = useState<string>("0x");
    const [amount, setAmount] = useState<string>("0");

    const { writeContract } = useWriteContract();

    const funcionSubmit = () => {
      writeContract({
        abi: MOCK_USDC_ABI,
        address: MOCK_TOKEN_ADDRESS,
        functionName: "mint",
        args: [
          userAddress as `0x${string}`,
          parseUnits(amount, decimals || 18),
        ],
      });
    };

    return (
      <div className="bg-white text-black">
        <div className="gap-2 justify-between">
          <label>Address user</label>
          <input
            className="border-black border-2"
            onChange={(e) => setUserAddress(e.target.value)}
          />
        </div>
        <div>
          <label>Amount</label>
          <input
            type="number"
            className="border-black border-2"
            onChange={(e) => setAmount(e.target.value)}
          />
        </div>
        <button
          className="bg-blue-400 text-black rounded-lg p-4"
          onClick={funcionSubmit}
        >
          Mint~
        </button>
      </div>
    );
  };

  return (
    <div>
      <ConnectButton />
      <p>Token Name : {name}</p>
      <p>Symbol: {symbol}</p>
      <p>Decimals: {decimals}</p>
      <BalanceUser />
      <h1>~Mint~</h1>
      <MintComponent />
    </div>
  );
}
