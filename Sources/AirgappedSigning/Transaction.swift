//
//  Transaction.swift
//  AirgappedSigning_Example
//
//  Created by Wolf McNally on 4/23/19.
//
//  Copyright © 2019 Blockchain Commons.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

public struct Transaction: Codable, Checked {
    public let uid: UUID
    public let asset: String?
    public let inputs: [Input]?
    public let outputs: [Output]?
    public let inputSignatures: [InputSignature]?

    public func check() throws {
        if let asset = asset {
            try checkAsset(asset, context: "Transaction")
        }
        if let inputs = inputs {
            try checkNotEmpty(inputs, context: "Transaction.inputs")
        }
        if let outputs = outputs {
            try checkNotEmpty(outputs, context: "Transaction.outputs")
        }
        if let inputSignatures = inputSignatures {
            try checkNotEmpty(inputSignatures, context: "Transaction.inputSignatures")
        }
    }

    public struct Derivation: Codable, Checked {
        public let accountIndex: Int
        public let addressIndex: Int
        public let isChange: Bool

        public func check() throws {
            try checkNotNegative(accountIndex, context: "Derivation.accountIndex")
            try checkNotNegative(addressIndex, context: "Derivation.addressIndex")
        }

        private enum CodingKeys: String, CodingKey {
            case accountIndex
            case addressIndex
            case isChange
        }

        public init(accountIndex: Int, addressIndex: Int, isChange: Bool) throws {
            self.accountIndex = accountIndex
            self.addressIndex = addressIndex
            self.isChange = isChange
            try check()
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            accountIndex = try container.decode(Int.self, forKey: .accountIndex)
            addressIndex = try container.decode(Int.self, forKey: .addressIndex)
            isChange = try container.decodeIfPresent(Bool.self, forKey: .isChange) ?? false
            try check()
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(accountIndex, forKey: .accountIndex)
            try container.encode(addressIndex, forKey: .addressIndex)
            if isChange {
                try container.encode(true, forKey: .isChange)
            }
        }
    }

    public struct Input: Codable, Checked {
        public let uid: UUID
        public let txHash: String
        public let inputIndex: Int
        public let sender: String
        public let derivation: Derivation
        public let amount: UInt64

        public func check() throws {
            try checkNotEmpty(txHash, context: "Input.txHash")
            try checkNotNegative(inputIndex, context: "Input.inputIndex")
            try checkNotEmpty(sender, context: "Input.sender")
            try derivation.check()
            try checkPositive(amount, context: "Input.amount")
        }

        public init(uid: UUID, txHash: String, inputIndex: Int, sender: String, derivation: Derivation, amount: UInt64) throws {
            self.uid = uid
            self.txHash = txHash
            self.inputIndex = inputIndex
            self.sender = sender
            self.derivation = derivation
            self.amount = amount
            try check()
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uid = try container.decode(UUID.self, forKey: .uid)
            txHash = try container.decode(String.self, forKey: .txHash)
            inputIndex = try container.decode(Int.self, forKey: .inputIndex)
            sender = try container.decode(String.self, forKey: .sender)
            derivation = try container.decode(Derivation.self, forKey: .derivation)
            amount = try container.decode(UInt64.self, forKey: .amount)
            try check()
        }
    }

    public struct Output: Codable, Checked {
        public let uid: UUID
        public let receiver: String
        public let amount: UInt64
        public let derivation: Derivation?

        public func check() throws {
            try checkNotEmpty(receiver, context: "Output.receiver")
            try checkPositive(amount, context: "Output.amount")
        }

        public init(uid: UUID, receiver: String, amount: UInt64, derivation: Derivation?) throws {
            self.uid = uid
            self.receiver = receiver
            self.amount = amount
            self.derivation = derivation
            try check()
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uid = try container.decode(UUID.self, forKey: .uid)
            receiver = try container.decode(String.self, forKey: .receiver)
            amount = try container.decode(UInt64.self, forKey: .amount)
            derivation = try container.decodeIfPresent(Derivation.self, forKey: .derivation)
            try check()
        }
    }

    public struct InputSignature: Codable, Checked {
        public let uid: UUID
        public let ecPublicKey: Data
        public let ecSignature: Data

        public func check() throws {
            try checkNotEmpty(ecPublicKey, context: "InputSignature.ecPublicKey")
            try checkNotEmpty(ecSignature, context: "InputSignature.ecSignature")
        }

        public init(uid: UUID, ecPublicKey: Data, ecSignature: Data) throws {
            self.uid = uid
            self.ecPublicKey = ecPublicKey
            self.ecSignature = ecSignature
            try check()
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uid = try container.decode(UUID.self, forKey: .uid)
            ecPublicKey = try container.decode(Data.self, forKey: .ecPublicKey)
            ecSignature = try container.decode(Data.self, forKey: .ecSignature)
            try check()
        }
    }
}
