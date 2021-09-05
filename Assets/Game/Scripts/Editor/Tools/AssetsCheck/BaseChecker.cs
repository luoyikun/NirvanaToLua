using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;
using Nirvana;

namespace AssetsCheck
{ 
    public class BaseChecker
    {
        protected List<ICheckItem> outputList = new List<ICheckItem>();
        private string fileName;
        private int errorCount;

        // 缓存的错误条数
        public int ErrorCount
        {
            get { return this.errorCount; }
        }

        public void StartCheck()
        {
            outputList.Clear();
            this.OnCheck();
        }

        public void StartFix()
        {
            this.OnFix(File.ReadAllLines(Path.Combine(AssetsCheckConfig.OutputDir, this.fileName + ".txt")));
        }

        // 获得错误描述
        public virtual string GetErrorDesc()
        {
            return "没有对该类型错误进行任何描述";
        }

        protected virtual void OnCheck()
        {
            Debug.LogError("No check scheme Provided");
        }

        protected virtual void OnFix(string[] lines)
        {
            Debug.LogError("没有提供自动解决方式，请手动解决");
        }

        public void SetFileName(string fileName)
        {
            this.fileName = fileName;
        }

        public string GetFileName()
        {
            return this.fileName;
        }

        public void Output()
        {
            this.FilterOutputList();
            this.outputList.RemoveDuplicate();

            this.errorCount = this.outputList.Count;
            StringBuilder builder = new StringBuilder();
            foreach (var item in this.outputList)
            {
                builder.Append(item.Output());
                builder.Append("\n");
            }

            File.WriteAllText(Path.Combine(AssetsCheckConfig.OutputDir, this.fileName + ".txt"), builder.ToString());
        }

        // 如果已在对应的过滤列表，则将出输出列表中排除
        private void FilterOutputList()
        {
            string path = Path.Combine(AssetsCheckConfig.ExcludeDir, this.fileName);
            if (!File.Exists(path))
            {
                return;
            }

            string[] lines = File.ReadAllLines(path);
            HashSet<string> hash_set = new HashSet<string>();
            for (int i = 0; i < lines.Length; i++)
            {
                hash_set.Add(lines[i]);
            }

            this.outputList.RemoveAll((ICheckItem item) =>
            {
                if (hash_set.Contains(item.MainKey))
                {
                    return true;
                }

                return false;
            });
        }

        // 获得错误资源列表
        protected string[] GetErrors()
        {
            string path = Path.Combine(AssetsCheckConfig.OutputDir, this.fileName);
            if (!File.Exists(path))
            {
                return new string[] { };
            }

            return File.ReadAllLines(Path.Combine(AssetsCheckConfig.OutputDir, this.fileName));
        }
    }

    public interface ICheckItem
    {
        string MainKey { get; }
        StringBuilder Output();
    }
}
