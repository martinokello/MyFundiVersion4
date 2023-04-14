using Microsoft.EntityFrameworkCore;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.UnitOfWork.Interfaces;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundiProfile.ServiceEndPoint.GeneralSevices
{
    public class ServicesEndPoint
    {
        MyFundiUnitOfWork _myFundiProfileUnitOfWork;
        IMailService _emailServices;
        public ServicesEndPoint(MyFundiUnitOfWork unitOfWork, IMailService emailServices)
        {
            _myFundiProfileUnitOfWork = unitOfWork;
            _emailServices = emailServices;
        }
        public async Task<Location[]> GetAllLocations()
        {
            var location = _myFundiProfileUnitOfWork._locationRepository.GetAll().ToArray();
            return await Task.FromResult(location);
        }

        public async Task<Company> GetCompanyById(int companyId)
        {
            try
            {
                var actComUnit = _myFundiProfileUnitOfWork._companyRepository.GetById(companyId);
                if (actComUnit == null)
                {
                    return null;
                }
                return await Task.FromResult(actComUnit);
            }
            catch (Exception e)
            {
                return null;
            }
        }

        public async Task<bool> PostCreateAddress(Address address)
        {
            try
            {
                var result = _myFundiProfileUnitOfWork._addressRepository.Insert(address);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public Task<FundiProfile[]> GetAllFundiProfilesByCompanyId(int companyId)
        {
            throw new NotImplementedException();
        }

        public async Task<bool> PostCreateLocation(Location location)
        {
            try
            {
                var result = _myFundiProfileUnitOfWork._locationRepository.Insert(location);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public Tuple<int, int> GetFundiProfileRatingById(int fundiProfileId)
        {
            return _myFundiProfileUnitOfWork.MyFundiDBContext.GetFundiProfileAvgRatingById(fundiProfileId);

        }

        public async Task<bool> UpdateAddress(Address address)
        {
            try
            {
                var result = _myFundiProfileUnitOfWork._addressRepository.Update(address);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public async Task<Address> SelectAddress(Address address)
        {
            try
            {
                var actAddress = _myFundiProfileUnitOfWork._addressRepository.GetById(address.AddressId);
                if (actAddress == null)
                {
                    return null;
                }
                return await Task.FromResult(actAddress);
            }
            catch (Exception e)
            {
                return null;
            }
        }
        public async Task<Location> SelectLocation(Location location)
        {
            try
            {
                var actlocation = _myFundiProfileUnitOfWork._locationRepository.GetById(location.LocationId);
                if (actlocation == null)
                {
                    return null;
                }
                return await Task.FromResult(actlocation);
            }
            catch (Exception e)
            {
                return null;
            }
        }

        public async Task<bool> DeleteAddress(Address address)
        {
            try
            {
                var actAddress = _myFundiProfileUnitOfWork._addressRepository.GetById(address.AddressId);
                if (actAddress == null)
                {
                    return await Task.FromResult(false);
                }
                var result = _myFundiProfileUnitOfWork._addressRepository.Delete(actAddress);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public async Task<Address[]> GetAllAddresses()
        {
            return await Task.FromResult(_myFundiProfileUnitOfWork._addressRepository.GetAll().ToArray());

        }
        public async Task<bool> DeleteLocation(Location location)
        {
            try
            {
                var actlocation = _myFundiProfileUnitOfWork._locationRepository.GetById(location.LocationId);
                if (actlocation == null)
                {
                    return await Task.FromResult(false);
                }
                var result = _myFundiProfileUnitOfWork._locationRepository.Delete(actlocation);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public async Task<bool> UpdateLocation(Location location)
        {
            try
            {
                var result = _myFundiProfileUnitOfWork._locationRepository.Update(location);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public async Task<bool> PostCreateCompany(Company company)
        {
            try
            {
                var result = _myFundiProfileUnitOfWork._companyRepository.Insert(company);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public Task<FundiProfile[]> GetFundisByCompanyId(int companyId)
        {
            throw new NotImplementedException();
        }

        public async Task<bool> UpdateCompany(Company company)
        {
            try
            {
                var result = _myFundiProfileUnitOfWork._companyRepository.Update(company);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public async Task<Company> SelectCompany(Company company)
        {
            try
            {
                var actCompany = _myFundiProfileUnitOfWork._companyRepository.GetById(company.CompanyId);
                if (actCompany == null)
                {
                    return null;
                }
                return await Task.FromResult(actCompany);
            }
            catch (Exception e)
            {
                return null;
            }
        }

        public async Task<bool> DeleteCompany(Company company)
        {
            try
            {
                var actcompany = _myFundiProfileUnitOfWork._companyRepository.GetById(company.CompanyId);
                if (actcompany == null)
                {
                    return await Task.FromResult(false);
                }
                var result = _myFundiProfileUnitOfWork._companyRepository.Delete(actcompany);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(result);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }
        public async Task<Company[]> GetAllCompanies()
        {
            return await Task.FromResult(_myFundiProfileUnitOfWork._companyRepository.GetAll()?.Include(q => q.Location).ThenInclude(q => q.Address).Select(q => q).ToArray());
        }

        public async Task<bool> CreateLocation(Location locationDefault)
        {
            var res = false;
            var location = _myFundiProfileUnitOfWork._locationRepository.GetAll()?.FirstOrDefault(q => q.LocationName == locationDefault.LocationName);
            if (location == null)
            {
                res = _myFundiProfileUnitOfWork._locationRepository.Insert(locationDefault);
                _myFundiProfileUnitOfWork.SaveChanges();
            }
            return await Task.FromResult(res);
        }

        public async Task<bool> CreateAddress(Address defaultAddress)
        {
            bool res = false;
            var address = _myFundiProfileUnitOfWork._addressRepository.GetAll()?.FirstOrDefault(q => q.AddressLine1.ToLower() == defaultAddress.AddressLine1.ToLower() && q.PostCode.ToLower() == defaultAddress.PostCode.ToLower());
            if (address == null)
            {
                res = _myFundiProfileUnitOfWork._addressRepository.Insert(defaultAddress);
                _myFundiProfileUnitOfWork.SaveChanges();
            }
            return await Task.FromResult(res);
        }

        public async Task<bool> CreateCompany(Company companyDefault)
        {
            var res = false;
            var company = _myFundiProfileUnitOfWork._companyRepository.GetAll()?.FirstOrDefault(q => q.CompanyName.ToLower() == companyDefault.CompanyName.ToLower());
            if (company == null)
            {
                res = _myFundiProfileUnitOfWork._companyRepository.Insert(companyDefault);
                _myFundiProfileUnitOfWork.SaveChanges();
            }
            return await Task.FromResult(res);
        }


        public async Task<Address> GetAddressById(int addressId)
        {
            return await Task.FromResult(_myFundiProfileUnitOfWork._addressRepository.GetById(addressId));
        }


        public async Task<Location> GetLocationById(int locationId)
        {
            return await Task.FromResult(_myFundiProfileUnitOfWork._locationRepository.GetById(locationId));
        }

        public User GetUserByEmailAddress(string email)
        {
            return _myFundiProfileUnitOfWork._userRepository.GetAll()?.First(q => q.Email.ToLower().Equals(email.ToLower()));
        }

        public async Task<bool> PostLocation(Location location)
        {
            try
            {
                _myFundiProfileUnitOfWork._addressRepository.Insert(location.Address);
                _myFundiProfileUnitOfWork.SaveChanges();
                location.AddressId = location.Address.AddressId;
                _myFundiProfileUnitOfWork._locationRepository.Insert(location);
                _myFundiProfileUnitOfWork.SaveChanges();
                return await Task.FromResult(true);
            }
            catch (Exception e)
            {
                return await Task.FromResult(false);
            }
        }

        public FundiRatingAndReview[] GetFundiRatings(int fundiProfileId)
        {

            var fundiProfileRatings = _myFundiProfileUnitOfWork._fundiRatingsAndReviewRepository.GetAll().Include(q=> q.User).Where(q => q.FundiProfileId == fundiProfileId);

            return fundiProfileRatings.ToArray();
        }
    }

}
