/*
 * Copyright (C) 2016-2020 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace netdriver
{
    class CreateFile
    {
        public static String[] CreateFiles(String path, String[] filenames,bool isDelete)
        {
            if (Directory.Exists(path) && isDelete)
            {
                Directory.Delete(path,true);
            }
            if (!Directory.Exists(path))
            {
                try
                {
                    Directory.CreateDirectory(path);
                }
                catch (IOException e)
                {
                    Console.WriteLine(e);
                    return null;
                }
            }

            String[] files = new String[filenames.Length];
            for (int i = 0; i < filenames.Length; i++)
            {
                String file = Path.Combine(path, filenames[i]);
                if (File.Exists(file))
                {
                    File.Delete(file);
                }
                try
                {
                    var fileHanlder = File.Create(file);
                    fileHanlder.Close();//释放文件句柄
                    files[i] = file;
                }
                catch (IOException e)
                {
                    Console.WriteLine(e);
                    return null;
                }
            }
            return files;
        }
    }
}
