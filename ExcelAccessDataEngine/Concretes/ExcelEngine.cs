using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ExcelAccessDataEngine.DomainModel;
using ExcelAccessDataEngine.Interfaces;
using OfficeOpenXml.Core.ExcelPackage; 

namespace ExcelAccessDataEngine.Concretes
{
    public class ExcelEngine : IExcelReader
    {

        public UserBadgeTo[] ReadExcel(string FilePath)
        {
            List<UserBadgeTo> dataRows = new List<UserBadgeTo>();
            //Title Row:
            var excelRowNumber = 1;
            var fileInfo = new FileInfo(FilePath);

            

            using (var memoryStream = new MemoryStream())
            {
                using (var stream = fileInfo.OpenRead())
                {
                    byte[] buf = new byte[4096];
                    int bytesRead = -1;
                    while ((bytesRead = stream.Read(buf, 0, buf.Length)) > 0)
                    {
                        memoryStream.Write(buf, 0, bytesRead);
                    }
                    stream.Flush();
                    stream.Close();
                }
                memoryStream.Seek(0, SeekOrigin.Begin);
                using (var exPackage = new ExcelPackage(memoryStream))
                {
                    ExcelWorksheet wsht = null;

                    if (exPackage.Workbook.Worksheets.Count >  0)
                        wsht = exPackage.Workbook.Worksheets[0];
                    if (wsht == null)
                    {

                        throw (new Exception("Excel File Missing WorkSheet!"));
                    }
                    if (excelRowNumber == 1)
                    {
                        //Consume Title Header
                        excelRowNumber++;
                    }
                    while (true)
                    {
                        if (string.IsNullOrEmpty(wsht.Cell(0, excelRowNumber).Value as string)) break;

                        dataRows.Add(new UserBadgeTo
                        {
                            EmailAddress = wsht.Cell(0, excelRowNumber).Value,
                            CandidateFullName = wsht.Cell(1, excelRowNumber).Value,
                            CellPhoneNumber = wsht.Cell(2, excelRowNumber).Value,
                            ProvinceDelimitedByComma = wsht.Cell(3, excelRowNumber).Value,
                            BadgeType = wsht.Cell(0, excelRowNumber).Value
                        });

                        excelRowNumber++;
                    }

                }
            }
            return dataRows.ToArray();
        }
    }
}
