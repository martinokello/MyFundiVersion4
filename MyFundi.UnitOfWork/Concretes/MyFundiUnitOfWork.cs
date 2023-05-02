using MyFundi.DataAccess;
using MyFundi.Domain;
using MyFundi.UnitOfWork.Interfaces;
using MyFundi.Services.RepositoryServices.Concretes;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyFundi.UnitOfWork.Concretes
{
    public class MyFundiUnitOfWork : IUnitOfWork
    {
        public AddressRepository _addressRepository;
        public InvoiceRepository _invoiceRepository;
        public ItemRepository _itemRepository;
        public LocationRepository _locationRepository;
        public UserRepository _userRepository;
        public RolesRepository _rolesRepository;
        public UserInRolesRepository _userInRolesRepository;
        public CompanyRepository _companyRepository;
        public CertificationRepository _certificationRepository;
        public ClientFundiContractRepository _clientFundiContractRepository;
        public CourseRepository _courseRepository;
        public FundiProfileCertificationRepository _fundiProfileCertificationRepostiory;
        public FundiProfileCourseTakenRepository _fundiProfileCourseTakenRepository;
        public FundiProfileRepository _fundiProfileRepository;
        public FundiRatingsAndReviewRepository _fundiRatingsAndReviewRepository;
        public FundiWorkCategoryRepository _fundiWorkCategoryRepository;
        public WorkCategoryRepository _workCategoryRepository;
        public ClientProfileRepository _clientProfileRepository;
        public JobRepository _jobRepository;
        public JobWorkCategoryRepository _jobWorkCategoryRepository;
        public MonthlySubscriptionRepository _monthlySubscriptionRepository;
        public WorkSubCategoryRepository _workSubCategoryRepository;
        public FundiSubscriptionRepository _fundiSubscriptionRepository;
        public ClientSubscriptionRepository _clientSubscriptionRepository;
        public FundiLocationRepository _fundiLocationRepository;
        public FundiSubscriptionQueueRepository _fundiSubscriptionQueueRepository;
        public MonthlySubscriptionQueueRepository _monthlySubscriptionQueueRepository;
        public BlogsRepository _blogsRepository;
        public QuestionRepository _questionRepository;
        public AnswerRepository _answerRepository;
        public MyFundiDBContext MyFundiDBContext { get; set; }
        public MyFundiUnitOfWork(
            AbstractRepository<Address> addressRepository,
            AbstractRepository<Invoice> invoiceRepository,
            AbstractRepository<Item> itemRepository,
            AbstractRepository<Location> locationRepository,
            AbstractRepository<User> userRepository,
            AbstractRepository<Role> rolesRepository,
            AbstractRepository<UserRole> userInRolesRepository,
            AbstractRepository<Company> companyRepository,
            AbstractRepository<Certification> certificationRepository,
            AbstractRepository<ClientFundiContract> clientFundiContractRepository,
            AbstractRepository<Course> courseRepository,
            AbstractRepository<FundiProfileCertification> fundiProfileCertificationRepository,
            AbstractRepository<FundiProfileCourseTaken> fundiProfileCourseTakenRepository,
            AbstractRepository<FundiProfile> fundiProfileRepository,
            AbstractRepository<FundiRatingAndReview> fundiRatingsAndReviewRepository,
            AbstractRepository<FundiWorkCategory> fundiWorkCategoryRepository,
            AbstractRepository<WorkCategory> workCategoryRepository,
            AbstractRepository<ClientProfile> clientProfileRepository,
            AbstractRepository<Job> jobRepository,
            AbstractRepository<JobWorkCategory> jobWorkCategoryRepository,
            AbstractRepository<MonthlySubscription> monthlySubscriptionRepository,
            AbstractRepository<WorkSubCategory> workSubCategoryRepository,
            AbstractRepository<FundiSubscription> fundiSubscriptionRepository,
            AbstractRepository<FundiLocation> fundiLocationRepository,
            AbstractRepository<ClientSubscription> clientSubscriptionRepository,
            AbstractRepository<FundiSubscriptionQueue> fundiSubscriptionQueueRepository, 
            AbstractRepository<MonthlySubscriptionQueue> monthlySubscriptionQueueRepository,
            AbstractRepository<Blog> blogsRepository,
            AbstractRepository<Question> questionRepository,
            AbstractRepository<Answer> answerRepository,
            MyFundiDBContext myFundiDbContext)
        {
            this.MyFundiDBContext = myFundiDbContext;
            _addressRepository = addressRepository as AddressRepository;
            _addressRepository.MyFundiDBContext = myFundiDbContext;
            _invoiceRepository = invoiceRepository as InvoiceRepository;
            _invoiceRepository.MyFundiDBContext = myFundiDbContext;
            _itemRepository = itemRepository as ItemRepository;
            _itemRepository.MyFundiDBContext = myFundiDbContext;
            _locationRepository = locationRepository as LocationRepository;
            _locationRepository.MyFundiDBContext = myFundiDbContext;
            _userRepository = userRepository as UserRepository;
            _userRepository.MyFundiDBContext = myFundiDbContext;
            _rolesRepository = rolesRepository as RolesRepository;
            _rolesRepository.MyFundiDBContext = myFundiDbContext;
            _userInRolesRepository = userInRolesRepository as UserInRolesRepository;
            _userInRolesRepository.MyFundiDBContext = myFundiDbContext;
            _companyRepository = companyRepository as CompanyRepository;
            _companyRepository.MyFundiDBContext = myFundiDbContext;
            _certificationRepository = certificationRepository as CertificationRepository;
            _certificationRepository.MyFundiDBContext = myFundiDbContext;
            _clientFundiContractRepository = clientFundiContractRepository as ClientFundiContractRepository;
            _clientFundiContractRepository.MyFundiDBContext = myFundiDbContext;
            _courseRepository = courseRepository as CourseRepository;
            _courseRepository.MyFundiDBContext = myFundiDbContext;
            _fundiProfileCertificationRepostiory = fundiProfileCertificationRepository as FundiProfileCertificationRepository;
            _fundiProfileCertificationRepostiory.MyFundiDBContext = myFundiDbContext;
            _fundiProfileCourseTakenRepository = fundiProfileCourseTakenRepository as FundiProfileCourseTakenRepository;
            _fundiProfileCourseTakenRepository.MyFundiDBContext = myFundiDbContext;
            _fundiProfileRepository = fundiProfileRepository as FundiProfileRepository;
            _fundiProfileRepository.MyFundiDBContext = myFundiDbContext;
            _fundiRatingsAndReviewRepository = fundiRatingsAndReviewRepository as FundiRatingsAndReviewRepository;
            _fundiRatingsAndReviewRepository.MyFundiDBContext = myFundiDbContext;
            _fundiWorkCategoryRepository = fundiWorkCategoryRepository as FundiWorkCategoryRepository;
            _fundiWorkCategoryRepository.MyFundiDBContext = myFundiDbContext;
            _workCategoryRepository = workCategoryRepository as WorkCategoryRepository;
            _workCategoryRepository.MyFundiDBContext = myFundiDbContext;
            _clientProfileRepository = clientProfileRepository as ClientProfileRepository;
            _clientProfileRepository.MyFundiDBContext = myFundiDbContext;
            _jobRepository = jobRepository as JobRepository;
            _jobRepository.MyFundiDBContext = myFundiDbContext;
            _jobWorkCategoryRepository = jobWorkCategoryRepository as JobWorkCategoryRepository;
            _jobWorkCategoryRepository.MyFundiDBContext = myFundiDbContext;
            _monthlySubscriptionRepository = monthlySubscriptionRepository as MonthlySubscriptionRepository;
            _monthlySubscriptionRepository.MyFundiDBContext = myFundiDbContext;
            _workSubCategoryRepository = workSubCategoryRepository as WorkSubCategoryRepository;
            _workSubCategoryRepository.MyFundiDBContext = myFundiDbContext;
            _fundiSubscriptionRepository = fundiSubscriptionRepository as FundiSubscriptionRepository;
            _fundiSubscriptionRepository.MyFundiDBContext = myFundiDbContext;
            _clientSubscriptionRepository = clientSubscriptionRepository as ClientSubscriptionRepository;
            _clientSubscriptionRepository.MyFundiDBContext = myFundiDbContext;
            _fundiLocationRepository = fundiLocationRepository as FundiLocationRepository;
            _fundiLocationRepository.MyFundiDBContext = myFundiDbContext;
            _fundiSubscriptionQueueRepository = fundiSubscriptionQueueRepository as FundiSubscriptionQueueRepository;
            _fundiSubscriptionQueueRepository.MyFundiDBContext = myFundiDbContext;
            _monthlySubscriptionQueueRepository = monthlySubscriptionQueueRepository as MonthlySubscriptionQueueRepository;
            _monthlySubscriptionQueueRepository.MyFundiDBContext = myFundiDbContext;
            _blogsRepository = blogsRepository as BlogsRepository;
            _blogsRepository.MyFundiDBContext = myFundiDbContext;
            _questionRepository = questionRepository as QuestionRepository;
            _questionRepository.MyFundiDBContext = myFundiDbContext;
            _answerRepository = answerRepository as AnswerRepository;
            _answerRepository.MyFundiDBContext = myFundiDbContext;
        }
        public void SaveChanges()
        {
            MyFundiDBContext.SaveChanges();
        }
    }
}
