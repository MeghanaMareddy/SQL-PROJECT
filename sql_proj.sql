create database employee_management;
use employee_management;
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from jobdepartment;
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from salarybonus;
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from employee;
-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from qualification;
-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from leaves;
-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from payroll;


-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
select * from employee;
select count(emp_id) from employee;

-- Which departments have the highest number of employees?
select * from jobdepartment;
select * from employee;
select count(e.emp_id) as highest_employee_count,j.jobdept from employee as e join jobdepartment as j on e.job_id=j.job_id group by jobdept order by highest_employee_count desc;

-- What is the average salary per department?
select * from jobdepartment;
select avg(p.total_amount) as average_salary,j.jobdept 
from payroll as p 
join jobdepartment as j 
on p.job_id=j.job_id 
group by j.jobdept;

select jd.jobdept, AVG(sb.amount)
from SalaryBonus sb
join JobDepartment jd 
on sb.Job_ID = jd.Job_ID
group by jd.jobdept;


-- Who are the top 5 highest-paid employees?
select * from employee;
select * from payroll;
select p.total_amount,e.emp_id,e.firstname 
from payroll as p
join employee as e
on p.emp_id=e.emp_id
order by total_amount desc
limit 5;


select * from salarybonus;
select e.firstname, sb.amount
from Employee e
join SalaryBonus sb ON e.Job_ID = sb.Job_ID
order by sb.amount desc
limit 5;

-- What is the total salary expenditure across the company?
select sum(amount) as total_salary_expenditure from salarybonus;
select sum(total_amount) as total_salary_expenditure from payroll;
-- “Total salary expenditure is calculated using the Payroll table 
-- because it reflects the actual salary paid after considering bonuses and leave deductions".
-- where as salary table conatins base salary.

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
select * from jobdepartment;
select count( distinct name) as diff_job_roles_count,jobdept from jobdepartment group by jobdept;

-- What is the average salary range per department?
select * from salarybonus;
select avg(s.amount),j.jobdept from salarybonus as s join jobdepartment as j on s.job_id=j.job_id group by j.jobdept;

-- Which job roles offer the highest salary?
select * from salarybonus;
select * from jobdepartment;
select s.amount,j.name as job_role from salarybonus as s join jobdepartment as j on s.job_id=j.job_id order by s.amount desc;


--  Which departments have the highest total salary allocation?
select sum(s.amount) as total_salary,j.jobdept
from salarybonus as s
join jobdepartment as j
on s.job_id=j.job_id
group by j.jobdept
order by total_salary desc;


-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
select * from qualification;
select * from employee;
select * from jobdepartment;
select count(distinct emp_id) as emp_with_qualification from qualification;

--  Which positions require the most qualifications?
select position,count(*) as total_qualification from qualification group by position order by total_qualification desc;

-- Which employees have the highest number of qualifications?
select e.emp_ID,e.firstname,COUNT(q.qualid) AS total_qualifications
from Employee e
join Qualification q 
on e.emp_ID = q.emp_ID
group by e.emp_ID, e.firstname
order by total_qualifications DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
--  Which year had the most employees taking leaves?
select * from leaves;
select YEAR(date) AS year,COUNT(DISTINCT emp_ID) AS employees_on_leave
from Leaves
group by YEAR(date)
order by employees_on_leave DESC;


-- What is the average number of leave days taken by its employees per department?
select * from employee;

select j.jobdept,COUNT(l.leave_ID) AS avg_leave_days
from Employee e
join JobDepartment j 
on e.Job_ID = j.Job_ID
left join Leaves l 
on e.emp_ID = l.emp_ID
group by j.jobdept;

select j.jobdept,
       COUNT(l.leave_ID) / COUNT(e.emp_ID) AS avg_leave_days
from Employee e
join JobDepartment j 
on e.Job_ID = j.Job_ID
left join Leaves l 
on e.emp_ID = l.emp_ID
group by j.jobdept;

-- COUNT(l.leave_ID) → total leave days in department
-- COUNT(e.emp_ID) → total employees
-- Divide → average leave days per employee

-- Which employees have taken the most leaves?
select * from employee;
select * from leaves;
select e.emp_id,e.firstname,count(l.leave_id) as count_of_leaves from leaves as l join employee as e on l.emp_id=e.emp_id group by e.emp_id,e.firstname order by count_of_leaves desc;

--  What is the total number of leave days taken company-wide?
select count(*) AS total_leave_days
from Leaves;

-- How do leave days correlate with payroll amounts?
select * from leaves;
select * from payroll;
select e.emp_ID,
       e.firstname,
       count(l.leave_ID) AS total_leaves,
       avg(p.total_amount) AS avg_salary
from Employee e
left join Leaves l 
on e.emp_ID = l.emp_ID
join Payroll p 
on e.emp_ID = p.emp_ID
group by e.emp_ID, e.firstname
order by  total_leaves desc;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
select * from payroll;
select sum(total_amount),report from payroll group by report;
-- or
select DATE_FORMAT(date, '%Y-%m') AS month,SUM(total_amount) AS total_monthly_payroll
from Payroll
group by DATE_FORMAT(date, '%Y-%m')
order by month;

-- What is the average bonus given per department?
select * from salarybonus;
select avg(s.bonus),j.jobdept
from salarybonus as s
join jobdepartment as j
on s.job_id=j.job_id
group by j.jobdept;

-- Which department receives the highest total bonuses?
select sum(s.bonus) as total_bonus,j.jobdept
from salarybonus as s
join jobdepartment as j
on s.job_id=j.job_id
group by jobdept
order by total_bonus desc;

-- What is the average value of total_amount after considering leave deductions?
select * from payroll;
select avg(total_amount) as avg_payroll_after_deductions from payroll;





