using ExcelAccessDataEngine.DomainModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExcelAccessDataEngine.Interfaces
{
    public interface IExcelReader
    {
        UserBadgeTo[] ReadExcel(string FilePath);
    }
}
