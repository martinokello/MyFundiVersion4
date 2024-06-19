using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using System.IO;
using System.Threading.Tasks;

namespace MyFundi.Web.Controllers
{
    public class FileContentServeController : Controller
    {
        private IHostingEnvironment Environment;
        public FileContentServeController(IHostingEnvironment environment)
        {
            this.Environment = environment;
        }
        [HttpGet]
        [Route("~/FileContentServe/GetImageSrcFromImageRootDirectory/{imageNameWithExtension}")]
        public async Task<IActionResult> GetImageSrcFromImageRootDirectory(string imageNameWithExtension)
        {
            string contentPath = this.Environment.ContentRootPath;

            string imagePath = contentPath + "\\images\\"+ imageNameWithExtension;

            var profInfo = new FileInfo(imagePath);
            using (var stream = profInfo.OpenRead())
            {
                byte[] bytes = new byte[4096];
                int bytesRead = 0;
                Response.ContentType = "image/"+ imageNameWithExtension.Substring(imageNameWithExtension.LastIndexOf("."));
                using (var wstr = Response.BodyWriter.AsStream())
                {
                    while ((bytesRead = stream.Read(bytes, 0, bytes.Length)) > 0)
                    {
                        wstr.Write(bytes, 0, bytesRead);
                    }
                    wstr.Flush();
                    wstr.Close();
                }
            }
            return await Task.FromResult(Ok(new { Message = "Profile Image downloaded Successfully" }));
        }
    }
}
