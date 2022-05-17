import { ADDRESS_ZERO, advanceBlock, advanceBlockTo, advanceTime, advanceTimeAndBlock, deploy, getBigNumber, prepare } from "./utilities"

import { expect } from "chai";
import { ethers } from "hardhat";


describe("Subscription Manager", function () {

  before(async function () {
    await prepare(this, ["ERC20Mock", "SubscriptionManager"])
  })


  beforeEach(async function () {
    await deploy(this, [["tokenMock1", this.ERC20Mock, ["Payment Token1 Mock", "PT1", getBigNumber(10000)]]])
    await deploy(this, [["subscriptionManager", this.SubscriptionManager]])
  })


  it("Plan can be created", async function () {
    const createPlanTx = await this.subscriptionManager.createSubscriptionPlan(this.tokenMock1.address, getBigNumber(10), 60 * 60 * 24 * 30)
    const planCreatedEvent = (await createPlanTx.wait()).events.filter(x => x.event == "SubscriptionPlanCreated")[0]
    expect(planCreatedEvent.args["creator"]).to.be.equal(this.alice.address)
    expect(planCreatedEvent.args["planId"]).to.be.equal(0)

    expect(await this.subscriptionManager.creator(0)).to.be.equal(this.alice.address)
    expect(await this.subscriptionManager.token(0)).to.be.equal(this.tokenMock1.address)
    expect(await this.subscriptionManager.price(0)).to.be.equal(getBigNumber(10))
    expect(await this.subscriptionManager.period(0)).to.be.equal(60 * 60 * 24 * 30)
  });
});