//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

namespace Game
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;
    using LuaInterface;
    using UnityEditor;

    /// <summary>
    /// The profiler for the lua.
    /// </summary>
    public static class LuaProfiler
    {
        private const int LUA_HOOKCALL = 0;
        private const int LUA_HOOKRET = 1;
        private const int ProfileMask = (1 << LUA_HOOKCALL) | (1 << LUA_HOOKRET);

        private static Stack<CallInfo> callStack = new Stack<CallInfo>();

        private static Dictionary<string, CallStats> summaryStats = 
            new Dictionary<string, CallStats>();

        /// <summary>
        /// Gets a value to indicating whether the lua is valid for profiling.
        /// </summary>
        public static bool IsValid
        {
            get
            {
                return GameRoot.Instance != null &&
                    GameRoot.Instance.LuaState != null;
            }
        }

        /// <summary>
        /// Gets a value to indicating whether the lua is profiling.
        /// </summary>
        public static bool Profiling { get; private set; }

        /// <summary>
        /// Gets the summary statistics.
        /// </summary>
        public static IDictionary<string, CallStats> SummaryStats
        {
            get
            {
                return summaryStats;
            }
        }

        /// <summary>
        /// Start to profile.
        /// </summary>
        public static void Start()
        {
            if (Profiling)
            {
                return;
            }

            Profiling = true;
            var luaState = GameRoot.Instance.LuaState;
            luaState.LuaSetHook(TraceHandler, ProfileMask, 0);
            GameRoot.Instance.StopEvent += Stop;
            GameRoot.Instance.UpdateEvent += Update;
        }

        /// <summary>
        /// Stop the profiling.
        /// </summary>
        public static void Stop()
        {
            Profiling = false;
            var luaState = GameRoot.Instance.LuaState;
            luaState.LuaSetHook(null, ProfileMask, 0);
            GameRoot.Instance.StopEvent -= Stop;
            GameRoot.Instance.UpdateEvent -= Update;
        }

        public static void Update()
        {
            foreach (var item in summaryStats)
            {
                item.Value.Update();
            }
        }

        /// <summary>
        /// Clear the profile data.
        /// </summary>
        public static void Clean()
        {
            summaryStats.Clear();
        }

        /// <summary>
        /// Save the profile data to file as a CSV.
        /// </summary>
        public static void Save(string path)
        {
            using (var file = File.Open(path, FileMode.Create, FileAccess.Write))
            using (var writer = new StreamWriter(file))
            {
                file.WriteByte(239); // 0xEF
                file.WriteByte(187); // 0xBB
                file.WriteByte(191); // 0xBF

                writer.WriteLine(
                    "Name,Count,Total(ms),AvgTime(ms),MaxTime(ms),TotalTimeInFrame,TotalMem(kb),AvgMem(kb),MaxMem(kb)");
                foreach (var kv in summaryStats)
                {
                    var name = kv.Key;
                    var stats = kv.Value;

                    writer.WriteLine(
                        name + ',' +
                        stats.Count + ',' +
                        stats.Total * 1000 + ',' +
                        stats.AvgTime * 1000 + ',' +
                        stats.MaxTime * 1000 + ',' +
                        stats.TotalTimeInFrame * 1000 + "," +
                        stats.TotalMem + ',' +
                        stats.AvgMem + ',' +
                        stats.MaxMem + ',');
                }
            }
        }

        private static void TraceHandler(IntPtr L, ref Lua_Debug ar)
        {
            LuaDLL.lua_getinfo(L, "nS", ref ar);

            if (ar.short_src == "[C]" ||
                string.IsNullOrEmpty(ar.name) ||
                ar.name == "pairs" || 
                ar.name == "next" || 
                ar.linedefined <= 0)
            {
                return;
            }

            if (ar.eventcode == LUA_HOOKCALL)
            {
                OnMethodCall(ar.short_src, ar.linedefined, ar.name);
            }
            else if (ar.eventcode == LUA_HOOKRET)
            {
                OnMethodReturn(ar.short_src, ar.linedefined, ar.name);
            }
        }

        private static void OnMethodCall(string file, int line, string symbol)
        {
            var name = string.Format("{0}[{1}]: {2}", file, line, symbol);
            callStack.Push(new CallInfo()
            {
                Name = name,
                StartTime = EditorApplication.timeSinceStartup,
                StartMem = GameRoot.Instance.Collectgarbage("count"),
            });
        }

        private static void OnMethodReturn(string file, int line, string symbol)
        {
            var name = string.Format("{0}[{1}]: {2}", file, line, symbol);
            var now = EditorApplication.timeSinceStartup;
            var now_mem = GameRoot.Instance.Collectgarbage("count");
            while (callStack.Count > 0)
            {
                var info = callStack.Pop();
                if (info.Name == name)
                {
                    CallStats callStats;
                    if (!summaryStats.TryGetValue(name, out callStats))
                    {
                        callStats = new CallStats();
                        summaryStats.Add(name, callStats);
                    }

                    callStats.AddCost(now - info.StartTime, now_mem - info.StartMem);
                    break;
                }
            }
        }

        private struct CallInfo
        {
            public string Name;
            public double StartTime;
            public double StartMem;
        }

        /// <summary>
        /// The lua method call statistics.
        /// </summary>
        public class CallStats
        {
            private int count = 0;
            private double totalTime;
            private double maxTime;
            private double maxTotalTimeInFrame;
            private double totalTimeInFrame;

            private double totalMem;
            private double maxMem;

            /// <summary>
            /// Gets the call count of this method.
            /// </summary>
            public int Count
            {
                get { return this.count; }
            }

            /// <summary>
            /// Gets the total time of this method.
            /// </summary>
            public double Total
            {
                get { return this.totalTime; }
            }

            /// <summary>
            /// Gets the max time of this method.
            /// </summary>
            public double MaxTime
            {
                get { return this.maxTime; }
            }

            /// <summary>
            /// Gets the avrage time of this method.
            /// </summary>
            public double AvgTime
            {
                get { return this.totalTime / count; }
            }

            public double TotalTimeInFrame
            {
                get { return this.maxTotalTimeInFrame; }
            }

            public double TotalMem
            {
                get { return this.totalMem; }
            }

            public double MaxMem
            {
                get { return this.maxMem; }
            }

            public double AvgMem
            {
                get { return this.totalMem / count; }
            }

            /// <summary>
            /// Add cost to this statistics.
            /// </summary>
            public void AddCost(double cost, double mem)
            {
                ++ count;
                this.totalTime += cost;
                if (this.maxTime < cost)
                {
                    this.maxTime = cost;
                }

                this.totalTimeInFrame += cost;

                this.totalMem += mem;
                if (this.maxMem < mem)
                {
                    this.maxMem = mem;
                }
            }

            public void Update()
            {
                if (this.totalTimeInFrame > this.maxTotalTimeInFrame)
                {
                    this.maxTotalTimeInFrame = this.totalTimeInFrame;
                }
                this.totalTimeInFrame = 0;
            }
        }
    }
}
