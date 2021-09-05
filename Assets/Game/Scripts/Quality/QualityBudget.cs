//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

/// <summary>
/// 游戏品质的预算控制.
/// </summary>
public sealed class QualityBudget
{
    // 整体预算.
    private int budget;

    // 总负荷.
    private int payload;

    // 开启列表.
    private SortedDictionary<int, PayloadList> enableTable =
        new SortedDictionary<int, PayloadList>(
            new EnableComparer());

    // 关闭列表.
    private SortedDictionary<int, PayloadList> disableTable =
        new SortedDictionary<int, PayloadList>(
            new DisableComparer());

    /// <summary>
    /// 初始化预算参数.
    /// </summary>
    public QualityBudget(int budget)
    {
        this.budget = budget;
    }

    /// <summary>
    /// 获取当前的总预算.
    /// </summary>
    public int Budget
    {
        get { return this.budget; }
    }

    /// <summary>
    /// 获取当前的总负载.
    /// </summary>
    public int Payload
    {
        get { return this.payload; }
    }

    /// <summary>
    /// 增加一个负载.
    /// </summary>
    public PayloadHandle AddPayload(
        int priority, int payload, Action enable, Action disable)
    {
        // 判断应该开启还是关闭.
        if (this.payload + payload <= this.budget)
        {
            return this.AddPayloadAsEnable(
                priority, payload, enable, disable);
        }
        else
        {
            return this.AddPayloadWhenOverload(
                priority, payload, enable, disable);
        }
    }

    /// <summary>
    /// 删除一个负载对象.
    /// </summary>
    public void RemovePayload(PayloadHandle handle)
    {
        if (handle.EnableTable)
        {
            PayloadList list;
            if (this.enableTable.TryGetValue(handle.Priority, out list))
            {
                // 获取对象.
                var node = (LinkedListNode<PayloadItem>)handle.Node;
                var item = node.Value;

                // 降低整体负载.
                list.Payload -= item.Payload;
                this.payload -= item.Payload;

                // 删除这个节点.
                list.Remove(node);

                // 删除这个优先级.
                if (list.Count == 0)
                {
                    this.enableTable.Remove(handle.Priority);
                }
            }
        }
        else
        {
            PayloadList list;
            if (this.disableTable.TryGetValue(handle.Priority, out list))
            {
                // 获取对象.
                var node = (LinkedListNode<PayloadItem>)handle.Node;
                var item = node.Value;

                // 降低整体负载.
                list.Payload -= item.Payload;

                // 删除这个节点.
                list.Remove(node);

                // 删除这个优先级.
                if (list.Count == 0)
                {
                    this.disableTable.Remove(handle.Priority);
                }
            }
        }
    }

    /// <summary>
    /// 调整预算.
    /// </summary>
    public void SetBudget(int budget)
    {
        this.budget = budget;
        if (this.budget > this.payload)
        {
            this.Upgrade(this.budget);
        }
        else if (this.budget < this.payload)
        {
            this.Downgrade(this.budget);
        }
    }

    private PayloadHandle AddPayloadAsEnable(
        int priority, int payload, Action enable, Action disable)
    {
        // 保存到启动列表里面.
        PayloadList list;
        if (!this.enableTable.TryGetValue(priority, out list))
        {
            list = new PayloadList();
            this.enableTable.Add(priority, list);
        }

        // 执行启动.
        try
        {
            enable();
        }
        catch (Exception e)
        {
            Debug.LogError(e.Message);
        }

        this.payload += payload;
        list.Payload += payload;

        var payloadItem = new PayloadItem()
        {
            Payload = payload,
            Enable = enable,
            Disable = disable,
        };

        var node = list.AddLast(payloadItem);
        var handle = new PayloadHandle()
        {
            Priority = priority,
            Node = node,
            EnableTable = true,
        };

        payloadItem.Handle = handle;
        return handle;
    }

    private PayloadHandle AddPayloadWhenOverload(
        int priority, int payload, Action enable, Action disable)
    {
        // 累积统计一下是否有足够的空间来存放这个优先级的对象.
        int freePayload = this.budget - this.payload;
        foreach (var kv in this.enableTable)
        {
            if (kv.Key >= priority)
            {
                break;
            }
            else
            {
                freePayload += kv.Value.Payload;
            }
        }

        if (freePayload > payload)
        {
            var budget = this.budget - payload;
            this.Downgrade(budget);

            // 如果空闲空间充足，则降低到指定预算为止, 再作为开启物件添加.
            return this.AddPayloadAsEnable(
                priority, payload, enable, disable);
        }
        else
        {
            // 如果空闲空间不足, 则以Disable状态添加.
            return this.AddPayloadAsDisable(
                priority, payload, enable, disable);
        }
    }

    private PayloadHandle AddPayloadAsDisable(
        int priority, int payload, Action enable, Action disable)
    {
        // 执行屏蔽.
        try
        {
            disable();
        }
        catch(Exception e)
        {
            Debug.LogError(e.Message);
        }

        // 保存到屏蔽列表里面.
        PayloadList list;
        if (!this.disableTable.TryGetValue(priority, out list))
        {
            list = new PayloadList();
            this.disableTable.Add(priority, list);
        }

        var payloadItem = new PayloadItem()
        {
            Payload = payload,
            Enable = enable,
            Disable = disable,
        };

        var node = list.AddLast(payloadItem);
        var handle = new PayloadHandle()
        {
            Priority = priority,
            Node = node,
            EnableTable = false,
        };

        payloadItem.Handle = handle;
        return handle;
    }

    /// <summary>
    /// 自动升级知道匹配到指定的预算值.
    /// </summary>
    private void Upgrade(int budget)
    {
        // 提升品质, 从Disable列表中根据优先级取对象一个一个放入开启列表中.
        while (true)
        {
            if (this.disableTable.Count == 0)
            {
                break;
            }

            // 获取第一个需要打开的对象.
            var kv = this.disableTable.First();
            var priority = kv.Key;
            var disableList = kv.Value;
            if (disableList.Count == 0)
            {
                this.disableTable.Remove(kv.Key);
                continue;
            }

            // 算上这个对象打开的话,会超过整体预算么?
            var first = disableList.First;
            var item = first.Value;
            if (budget < this.payload + item.Payload)
            {
                break;
            }

            this.UpgradeItem(priority, disableList, first);
        }
    }

    private void UpgradeItem(
        int priority,
        PayloadList disableList,
        LinkedListNode<PayloadItem> first)
    {
        var item = first.Value;

        // 执行打开操作.
        try
        {
            item.Enable();
        }
        catch (Exception e)
        {
            Debug.LogError(e.Message);
        }

        // 从disable列表中删除, 加入到enable列表里面.
        disableList.Remove(first);

        // 删除这个优先级.
        if (disableList.Count == 0)
        {
            this.disableTable.Remove(priority);
        }

        PayloadList enableList;
        if (!this.enableTable.TryGetValue(priority, out enableList))
        {
            enableList = new PayloadList();
            this.enableTable.Add(priority, enableList);
        }

        var node = enableList.AddLast(item);

        // 更新Handle
        item.Handle.Node = node;
        item.Handle.EnableTable = true;

        // 调整负载.
        this.payload += item.Payload;
        disableList.Payload -= item.Payload;
        enableList.Payload += item.Payload;
    }

    /// <summary>
    /// 自动降级知道匹配到指定的预算值.
    /// </summary>
    private void Downgrade(int budget)
    {
        // 降低品质, 从Enable列表中根据优先级取对象一个一个放入开启列表中.
        while (this.payload > budget)
        {
            if (this.enableTable.Count == 0)
            {
                break;
            }

            // 获取第一个需要关闭的对象.
            var kv = this.enableTable.First();
            var priority = kv.Key;
            var enableList = kv.Value;
            if (enableList.Count == 0)
            {
                this.enableTable.Remove(kv.Key);
                continue;
            }

            // 这个对象关闭掉.
            this.DowngradeItem(priority, enableList, enableList.First);
        }
    }

    private void DowngradeItem(
        int priority,
        PayloadList enableList, 
        LinkedListNode<PayloadItem> first)
    {
        var item = first.Value;

        // 执行关闭操作.
        try
        {
            item.Disable();
        }
        catch (Exception e)
        {
            Debug.LogError(e.Message);
        }

        // 从enable列表中删除, 加入到disable列表里面.
        enableList.Remove(first);

        // 删除这个优先级.
        if (enableList.Count == 0)
        {
            this.enableTable.Remove(priority);
        }

        PayloadList disableList;
        if (!this.disableTable.TryGetValue(priority, out disableList))
        {
            disableList = new PayloadList();
            this.disableTable.Add(priority, disableList);
        }

        var node = disableList.AddLast(item);

        // 更新Handle
        item.Handle.Node = node;
        item.Handle.EnableTable = false;

        // 调整负载.
        this.payload -= item.Payload;
        enableList.Payload -= item.Payload;
        disableList.Payload += item.Payload;
    }

    /// <summary>
    /// 负载句柄对象.
    /// </summary>
    public class PayloadHandle
    {
        internal int Priority { get; set; }
        internal object Node { get; set; }
        internal bool EnableTable { get; set; }
    }

    /// <summary>
    /// 同一个优先级下的负载列表.
    /// </summary>
    private class PayloadList : LinkedList<PayloadItem>
    {
        /// <summary>
        /// 这个列表中的总负载.
        /// </summary>
        public int Payload { get; set; }
    }

    /// <summary>
    /// 品质开销的负载对象.
    /// </summary>
    private class PayloadItem
    {
        /// <summary>
        /// 负载开销.
        /// </summary>
        public int Payload { get; set; }

        /// <summary>
        /// 启动负载回调.
        /// </summary>
        public Action Enable { get; set; }

        /// <summary>
        /// 关闭负载回调.
        /// </summary>
        public Action Disable { get; set; }

        /// <summary>
        /// 该负载的节点对象.
        /// </summary>
        public PayloadHandle Handle { get; set; }
    }

    private class EnableComparer : IComparer<int>
    {
        public int Compare(int x, int y)
        {
            return x.CompareTo(y);
        }
    }

    private class DisableComparer : IComparer<int>
    {
        public int Compare(int x, int y)
        {
            return y.CompareTo(x);
        }
    }
}
