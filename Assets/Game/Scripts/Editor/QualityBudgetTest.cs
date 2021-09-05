//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using NUnit.Framework;

public class QualityBudgetTest
{
    [Test]
    public void TestAddToOverload()
    {
        var budget = new QualityBudget(1000);
        int enableCount = 0;
        int disableCount = 0;
        for (int i = 0; i < 15; ++i)
        {
            budget.AddPayload(
                1, 99, () => { ++enableCount; }, () => { ++disableCount; });
        }

        Assert.AreEqual(budget.Payload, 990);
        Assert.AreEqual(enableCount, 10);
        Assert.AreEqual(disableCount, 5);
    }

    [Test]
    public void TestAddAndRemove()
    {
        var budget = new QualityBudget(1000);
        var handle1 = budget.AddPayload(
            1, 1, () =>{}, () =>{});
        var handle2 = budget.AddPayload(
            1, 3, () => { }, () => { });
        var handle3 = budget.AddPayload(
            1, 5, () => { }, () => { });
        var handle4 = budget.AddPayload(
            1, 7, () => { }, () => { });
        var handle5 = budget.AddPayload(
            1, 11, () => { }, () => { });

        Assert.AreEqual(budget.Payload, 27);

        budget.RemovePayload(handle4);
        Assert.AreEqual(budget.Payload, 20);

        budget.RemovePayload(handle2);
        Assert.AreEqual(budget.Payload, 17);

        budget.RemovePayload(handle1);
        Assert.AreEqual(budget.Payload, 16);

        budget.RemovePayload(handle5);
        Assert.AreEqual(budget.Payload, 5);

        budget.RemovePayload(handle3);
        Assert.AreEqual(budget.Payload, 0);
    }

    [Test]
    public void TestAdjuestBudget()
    {
        var budget = new QualityBudget(1000);
        int enableCount = 0;
        int disableCount = 0;
        for (int i = 0; i < 15; ++i)
        {
            budget.AddPayload(
                1, 99, () => { ++enableCount; }, () => { ++disableCount; });
        }

        budget.SetBudget(500);

        Assert.AreEqual(budget.Payload, 495);
        Assert.AreEqual(enableCount, 10);
        Assert.AreEqual(disableCount, 10);
    }
}
