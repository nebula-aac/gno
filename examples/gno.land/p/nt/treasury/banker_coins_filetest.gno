// PKGPATH: gno.land/r/treasury/main

package main

import (
	"std"
	"testing"

	"gno.land/p/nt/treasury"
)

func main() {
	// Define addresses for the sender (owner) and destination.
	ownerAddr := std.DerivePkgAddr("gno.land/r/treasury/main")
	destAddr := std.DerivePkgAddr("gno.land/r/dest/main")

	// Create a CoinsBanker.
	banker := std.NewBanker(std.BankerTypeRealmSend)
	cbanker, err := treasury.NewCoinsBanker(banker)
	if err != nil {
		panic("failed to create CoinsBanker: " + err.Error())
	}

	println("CoinsBanker ID:", cbanker.ID())
	println("CoinsBanker Address:", cbanker.Address())

	// Check if the CoinsBanker address matches the owner address.
	if cbanker.Address() != ownerAddr.String() {
		panic("CoinsBanker address does not match current realm address")
	}

	println("CoinsBanker Balances count:", len(cbanker.Balances()))

	// Issue some coins to the owner address.
	testing.IssueCoins(ownerAddr, std.NewCoins(std.NewCoin("ugnot", 42)))

	println("CoinsBanker Balances count:", len(cbanker.Balances()))
	println("Ugnot balance:", cbanker.Balances()[0].Amount)

	// Send a valid payment.
	validPayment := treasury.NewCoinsPayment(
		std.NewCoins(std.NewCoin("ugnot", 10)),
		destAddr,
	)
	err = cbanker.Send(validPayment)
	println("Valid payment error:", err)
	if err != nil {
		panic("failed to send valid payment: " + err.Error())
	}

	println("Ugnot balance:", cbanker.Balances()[0].Amount)

	// Send a payment with an invalid type.
	invalidPaymentType := treasury.NewGRC20Payment("", 0, destAddr)
	err = cbanker.Send(invalidPaymentType)
	println("Invalid payment type error:", err)
	if err == nil {
		panic("expected error for invalid payment type, but got none")
	}

	// Issue another coin to the owner address to test the Balances method.
	testing.IssueCoins(ownerAddr, std.NewCoins(std.NewCoin("anothercoin", 1337)))

	println("CoinsBanker Balances count:", len(cbanker.Balances()))
}

// Output:
// CoinsBanker ID: Coins
// CoinsBanker Address: g1ynsdz5zaxhn9gnqtr6t40m5k4fueeutq7xy224
// CoinsBanker Balances count: 0
// CoinsBanker Balances count: 1
// Ugnot balance: 42
// Valid payment error: undefined
// Ugnot balance: 32
// Invalid payment type error: invalid payment type
// CoinsBanker Balances count: 2
