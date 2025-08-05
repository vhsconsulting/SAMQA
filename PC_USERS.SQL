
  CREATE OR REPLACE EDITIONABLE PACKAGE "SAMQA"."PC_USERS" IS
  TYPE user_info_row_t IS RECORD
  (
    user_id         NUMBER(10),
    user_name       VARCHAR2(255),
    password        VARCHAR2(255),
    site_key        VARCHAR2(1000),
    site_image       VARCHAR2(255),
    user_type       VARCHAR2(30),
    emp_reg_type    NUMBER(1),
    pw_question1    VARCHAR2(255),
    pw_answer1      VARCHAR2(255),
    pw_question2    VARCHAR2(255),
    pw_answer2      VARCHAR2(255),
    pw_question3    VARCHAR2(255),
    pw_answer3      VARCHAR2(255),
    remember_pc     VARCHAR2(255),
    no_of_accounts  NUMBER,
    tax_id          VARCHAR2(255),
    acc_num         VARCHAR2(255),
    account_type    VARCHAR2(255),
    acc_id          VARCHAR2(255),
    eob_status      VARCHAR2(255),
    change_password VARCHAR2(1),
    sec_grace_days   NUMBER,
    skip_security   VARCHAR2(1),
    sec_exist       VARCHAR2(1),
    portfolio_account VARCHAR2(1),
    confirmed_flag   VARCHAR2(1),
    redirect_url    VARCHAR2(255),
    display_name    VARCHAR2(255),
    password_sent   VARCHAR2(255),
    allow_login     VARCHAR2(255),
    error_message   VARCHAR2(1000),
    error_status    VARCHAR2(10),
    locked_account  VARCHAR2(10),
    pw_reminder_qut VARCHAR2(255),
    pw_reminder_ans VARCHAR2(255),
    email           VARCHAR2(255),
    sso_user        VARCHAR2(255),
    locked_reason   VARCHAR2(255),
    first_time_pw_flag VARCHAR2(1),
    logged_in       VARCHAR2(1),
    security_setup  VARCHAR2(1),
    otp_verified   VARCHAR2(1),
    verified_phone_number VARCHAR2(255),
    verified_phone_type   VARCHAR2(30),
    verified_email VARCHAR2(100),
    number_to_be_verified VARCHAR2(255),
    show_modal_window VARCHAR2(1),
    allow_broker_renewal VARCHAR2(2),  /*Ticket#6834 */
    allow_broker_enroll VARCHAR2(2),
    allow_broker_invoice VARCHAR2(2),
    acc_type_description VARCHAR2(100),
    allow_broker_Enroll_ee     VARCHAR2(2), --- 7781 added by rprabu on 17/05/2019
    allow_broker_Enroll_rpts   VARCHAR2(2), --- 7781 added by rprabu on 17/05/2019
    allow_broker_ee            VARCHAR2(2), --- 7781 added by rprabu on 17/05/2019
    show_td_ameritrade_page   VARCHAR2(1) ,    --- Added by Joshi for 6596
    Allow_bro_upd_pln_Doc     VARCHAR2(3),   --- Ticket#8728  added by rprabu on 18/02/2020
    employer_user_id          NUMBER,        --- Added by Joshi for 9902
    status                    VARCHAR2(20)   -- Added by Jaggi #11090 on 05/10/2022
   );

  TYPE user_info_t IS TABLE OF user_info_row_t ;

  TYPE user_roles_row_t  IS RECORD
  (site_nav_id  NUMBER
  ,user_id      NUMBER
  ,account_type VARCHAR2(30)
  ,nav_description  VARCHAR2(255));

  TYPE user_roles_t IS TABLE OF user_roles_row_t ;

 TYPE accounts_row_t  IS RECORD
   (acc_num                 VARCHAR2(30)
  ,account_type            VARCHAR2(30)
  ,meaning                 VARCHAR2(255)
  ,account_type_meaning    VARCHAR2(255)
  ,acc_balance             NUMBER
  ,account_status          VARCHAR2(30)
,account_status_meaning          VARCHAR2(100)      ------rprabu 9141 17/08/2020
  ,complete_flag           VARCHAR2(1)
  ,plan_count              NUMBER
  ,acc_id                  NUMBER
  ,entrp_id                NUMBER
  ,broker_id               NUMBER
  ,decline_date            DATE   -- Added by Swamy for Ticket#8949);
  ,Enrolle_Type            Varchar(30)   -- Added  By Rprabu For Ticket#9141 On 29/07/2020
  ,Enrolled_By             Number     -- Added  by rprabu for Ticket#9141    on 29/07/2020
  ,show_account_online     VARCHAR2(1)  -- Added  by Swamy for Ticket#9332 on 06/11/2020
  ,resubmit_flag           VARCHAR2(1)   -- Added  by Jaggi for Ticket#10430 on 04/11/2021
  ,inactive_plan_flag      VARCHAR2(1)     -- Added  by Joshi for Ticket#10430 on 04/11/2021
  ,Signature_account_status NUMBER              -- Added by Swamy for Tiecket#11364(Broker)
  );
  TYPE accounts_t IS TABLE OF accounts_row_t ;


 TYPE roles_row_t  IS RECORD
  (nav_code           VARCHAR2(30)
  ,redirect_url       VARCHAR2(255)
  ,url_description    VARCHAR2(255) );

  TYPE roles_t IS TABLE OF roles_row_t ;
  TYPE user_detail_row_t IS RECORD
  (user_name VARCHAR2(255)
  ,email     VARCHAR2(255)
  ,user_type VARCHAR2(30)
  ,confirmed_flag VARCHAR2(1)
  ,registered VARCHAR2(1)
  ,name VARCHAR2(30)
  ,account_type VARCHAR2(30)
  ,acc_num      VARCHAR2(30)
  ,enrollment_id NUMBER
  ,employer_id   VARCHAR2(30));

  TYPE user_det_t IS TABLE OF user_detail_row_t ;


   PROCEDURE INSERT_USERS
    (
     p_user_name    IN VARCHAR2
    ,p_password     IN VARCHAR2
    ,p_user_type    IN VARCHAR2
    ,p_emp_reg_type IN VARCHAR2 DEFAULT NULL
    ,p_find_key     IN VARCHAR2
    ,p_locked_time  IN VARCHAR2 DEFAULT NULL
    ,p_succ_access  IN NUMBER   DEFAULT NULL
    ,p_last_login   IN VARCHAR2 DEFAULT NULL
    ,p_failed_att   IN NUMBER   DEFAULT NULL
    ,p_failed_ip    IN VARCHAR2 DEFAULT NULL
    ,p_create_pw    IN VARCHAR2 DEFAULT NULL
    ,p_change_pw    IN VARCHAR2 DEFAULT NULL
    ,p_email        IN VARCHAR2
    ,p_pw_question  IN VARCHAR2
    ,p_pw_answer    IN VARCHAR2
    ,p_confirmed_flag IN VARCHAR2 DEFAULT 'N'
    ,p_tax_id       IN VARCHAR2 DEFAULT NULL
    ,x_user_id       OUT VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
    ,p_user_id       IN  NUMBER DEFAULT NULL
    );
   PROCEDURE INSERT_CONTACT_USER
    (
     p_user_name    IN VARCHAR2
    ,p_password     IN VARCHAR2
    ,p_user_type    IN VARCHAR2
    ,p_emp_reg_type IN VARCHAR2 DEFAULT NULL
    ,p_find_key     IN VARCHAR2
    ,p_locked_time  IN VARCHAR2 DEFAULT NULL
    ,p_succ_access  IN NUMBER   DEFAULT NULL
    ,p_last_login   IN VARCHAR2 DEFAULT NULL
    ,p_failed_att   IN NUMBER   DEFAULT NULL
    ,p_failed_ip    IN VARCHAR2 DEFAULT NULL
    ,p_create_pw    IN VARCHAR2 DEFAULT NULL
    ,p_change_pw    IN VARCHAR2 DEFAULT NULL
    ,p_email        IN VARCHAR2
    ,p_pw_question  IN VARCHAR2
    ,p_pw_answer    IN VARCHAR2
    ,p_confirmed_flag IN VARCHAR2 DEFAULT 'N'
    ,p_tax_id       IN VARCHAR2 DEFAULT NULL
    ,p_first_time_pw_flag IN VARCHAR2 DEFAULT 'N'
    ,x_user_id       OUT VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
  );
  PROCEDURE UPDATE_USERS
    (
     p_user_name    IN VARCHAR2
    ,p_password     IN VARCHAR2
    ,p_user_type    IN VARCHAR2
    ,p_emp_reg_type  IN VARCHAR2 DEFAULT NULL
    ,p_find_key     IN VARCHAR2
    ,p_email        IN VARCHAR2
    ,p_pw_question  IN VARCHAR2
    ,p_pw_answer    IN VARCHAR2
    ,p_user_id      IN VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
    );

  PROCEDURE DELETE_USERS
    (
     p_contact_user_id     IN VARCHAR2
    ,p_user_id      IN VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
    );

  FUNCTION check_user_locked
  ( p_user_name     IN VARCHAR2) return varchar2;

  FUNCTION get_email
  ( p_acc_num     IN VARCHAR2
  , p_acc_id      IN NUMBER
  , p_pers_id     IN NUMBER)
  return varchar2;

 FUNCTION validate_user
  ( p_tax_id      IN VARCHAR2
  , p_acc_num     IN VARCHAR2
  , p_user_type   IN VARCHAR2
  , p_emp_reg_type IN VARCHAR2
  , p_user_name   IN VARCHAR2
  , p_password    IN VARCHAR2
  , p_user_id     IN  NUMBER DEFAULT NULL)
  RETURN VARCHAR2;


  FUNCTION get_email_from_user_id
  ( p_user_id IN NUMBER)
  return varchar2;


  FUNCTION get_find_key (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2 DEFAULT 'S',P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
  RETURN VARCHAR2;
 FUNCTION get_user (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2 DEFAULT 'S',P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
  RETURN NUMBER;
 FUNCTION get_user_name (P_USER_ID IN NUMBER)
 RETURN VARCHAR2;
 FUNCTION get_user_id (P_USER_NAME IN VARCHAR2)
 RETURN NUMBER;
  FUNCTION get_user_count (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2 DEFAULT 'S',P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
  RETURN NUMBER;

  FUNCTION check_user_registered (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2)
  RETURN VARCHAR2;
  FUNCTION is_active_user (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2)
  RETURN VARCHAR2;
  FUNCTION is_portfolio_account(p_ssn IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION check_find_key (P_TAX_ID IN VARCHAR2,P_ACC_NUM IN VARCHAR2
                      , P_USER_TYPE IN VARCHAR2 DEFAULT 'S'
                      , P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
  RETURN NUMBER;

  FUNCTION is_confirmed (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION is_user_existing (P_USER_NAME IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION is_email_registered(P_TAX_ID IN VARCHAR2,P_email IN VARCHAR2)
  RETURN VARCHAR2;


  PROCEDURE reactivate_registration ( p_acc_num IN VARCHAR2 DEFAULT NULL , p_ssn IN VARCHAR2 DEFAULT NULL);
  PROCEDURE reactivate_er_registration ( p_acc_num IN VARCHAR2 DEFAULT NULL , p_ein IN VARCHAR2 DEFAULT NULL
                                     ,p_contact_user_id IN NUMBER DEFAULT NULL, p_user_id IN  NUMBER DEFAULT NULL);
  PROCEDURE inactivate_registration ( p_acc_num IN VARCHAR2 DEFAULT NULL
                                   ,p_user_id IN NUMBER DEFAULT NULL
                                   ,p_contact_user_id IN NUMBER DEFAULT NULL
                                   ,p_user_name IN VARCHAR2 DEFAULT NULL);
  PROCEDURE lock_user (p_user_id IN NUMBER, p_lock_reason IN VARCHAR2,p_ip_address IN VARCHAR2);
  PROCEDURE lock_user_with_ssn (p_ssn IN VARCHAR2, p_lock_reason IN VARCHAR2,p_ip_address IN VARCHAR2);



  PROCEDURE unlock_user(p_user_name IN VARCHAR2,p_password IN VARCHAR2);

  FUNCTION validate_ee_reg(p_acc_num IN VARCHAR2
                ,p_tax_id IN VARCHAR2
                ,p_user_name   IN VARCHAR2
                ,p_birth_date  IN VARCHAR2 )
  RETURN VARCHAR2;

  FUNCTION validate_er_reg(p_acc_num IN VARCHAR2
              ,p_tax_id IN VARCHAR2
              ,p_user_name   IN VARCHAR2
              ,p_zip_code  IN VARCHAR2 )
  RETURN VARCHAR2;
  FUNCTION get_user_info
        ( p_user_name IN VARCHAR2
        , p_password  IN VARCHAR2
        , p_skip_security IN VARCHAR2 DEFAULT 'N'
        , p_referrer  IN VARCHAR2 -- anticipating for future login request
        , p_sso_user  IN VARCHAR2 ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
  RETURN user_info_t PIPELINED DETERMINISTIC;
FUNCTION get_user_info_v2
        ( p_user_name IN VARCHAR2
        , p_password  IN VARCHAR2
        , p_skip_security IN VARCHAR2 DEFAULT 'N'
        , p_referrer  IN VARCHAR2 -- anticipating for future login request
        , p_sso_user  IN VARCHAR2 ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
RETURN user_info_t PIPELINED DETERMINISTIC;
  PROCEDURE reset_password ( p_user_name IN VARCHAR2
                           , p_password  IN VARCHAR2
                           , p_user_id   IN NUMBER);


   PROCEDURE create_role_entries (p_contact_user_id IN NUMBER
                              , p_role_entries    IN PC_ONLINE_ENROLLMENT.VARCHAR2_TBL
                              , p_user_id         IN NUMBER
                              , p_role_id         IN NUMBER
                              , p_authorize_req_id IN NUMBER	-- 9902 added by Joshi
                              , x_return_status OUT VARCHAR2
                              , x_error_message OUT VARCHAR2);
  PROCEDURE set_password ( p_user_name IN VARCHAR2
                       , p_password  IN VARCHAR2
                       , p_pw_question IN VARCHAR2
                           , p_pw_answer   IN VARCHAR2);
  FUNCTION get_user_permissions ( p_user_id IN NUMBER,p_role_type IN NUMBER)
  RETURN user_roles_t PIPELINED DETERMINISTIC;

  FUNCTION get_permissions ( p_user_id IN NUMBER,p_role_type IN NUMBER)
  RETURN user_roles_t PIPELINED DETERMINISTIC;

  FUNCTION get_forgotten_user
  ( p_user_name IN VARCHAR2
    , p_find_key  IN VARCHAR2
    , p_email     IN VARCHAR2)
  RETURN user_info_t PIPELINED DETERMINISTIC;


  PROCEDURE confirm_registration ( p_user_name     IN  VARCHAR2,
                                 x_return_status OUT VARCHAR2,
                                          x_error_message OUT VARCHAR2 );

  FUNCTION enroll_acc_exists (p_tax_id IN VARCHAR2)
  RETURN VARCHAR2;
  FUNCTION enroll_new_acct (p_user_id IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_email_from_taxid
  ( p_tax_id     IN VARCHAR2 )
  return varchar2;

  FUNCTION get_products ( p_user_id IN NUMBER)
  RETURN accounts_t PIPELINED DETERMINISTIC;

  FUNCTION show_alert (p_user_id IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION get_nav_list ( p_user_id IN NUMBER,p_account_type IN VARCHAR2
    ,p_is_broker       IN VARCHAR2 DEFAULT NULL
    ,p_broker_enroll   IN VARCHAR2 DEFAULT NULL
    ,p_broker_renewal  IN VARCHAR2 DEFAULT NULL
    ,p_broker_invoices IN VARCHAR2 DEFAULT NULL
	,p_broker_Enroll_ee  	 IN VARCHAR2 DEFAULT NULL  --- ticket 7781 prabu on 17/05/2019
    ,p_broker_Enroll_rpts    IN VARCHAR2 DEFAULT NULL  --- ticket 7781 prabu on 17/05/2019
    ,p_broker_ee 	         IN VARCHAR2 DEFAULT NULL    --- ticket 7781 prabu on 17/05/2019
	,p_Allow_bro_upd_pln_Doc IN VARCHAR2 DEFAULT NULL    --- ticket 8728  prabu on 18/02/2020
    ,p_tax_id  				 IN VARCHAr2 DEFAULT NULL)/*Ticket#6834 */
  RETURN roles_t PIPELINED DETERMINISTIC;

   --- rprabu 06/05/2020 #ticket 8837
   FUNCTION get_nav_list_v2_old
    ( p_user_id                           IN NUMBER
     ,p_account_type               IN VARCHAR2
     ,p_is_broker 		          	      IN VARCHAR2 DEFAULT NULL
     ,p_broker_enroll	        	  IN VARCHAR2 DEFAULT NULL
     ,p_broker_renewal 		  IN VARCHAR2 DEFAULT NULL
     ,p_broker_invoices   	      IN VARCHAR2 DEFAULT NULL
	 ,p_broker_Enroll_ee       IN VARCHAR2 DEFAULT NULL
     ,p_broker_Enroll_rpts     IN VARCHAR2 DEFAULT NULL
     ,p_broker_ee		               IN VARCHAR2 DEFAULT NULL
	 ,p_Allow_bro_upd_pln_Doc IN VARCHAR2 DEFAULT NULL
     ,p_tax_id        IN VARCHAR2 DEFAULT NULL)  RETURN pc_users.roles_t PIPELINED DETERMINISTIC;

  FUNCTION get_user_details( P_TAX_ID IN VARCHAR2, P_CONF_EMAIL_TYPE IN VARCHAR2)
  RETURN user_det_t PIPELINED DETERMINISTIC;

  FUNCTION get_ee_enrolled_products ( p_ssn IN VARCHAR2)
  RETURN accounts_t PIPELINED DETERMINISTIC;

  FUNCTION get_er_enrolled_products ( p_ein IN VARCHAR2)
  RETURN accounts_t PIPELINED DETERMINISTIC;

 FUNCTION get_user_info_by_uname(p_user_name IN VARCHAR2) RETURN user_info_t PIPELINED DETERMINISTIC;


  FUNCTION get_er_not_enrolled_plans( p_ein IN VARCHAR2)
  RETURN accounts_t PIPELINED DETERMINISTIC;

  FUNCTION get_all_products ( p_user_id IN NUMBER)
  RETURN accounts_t PIPELINED DETERMINISTIC;

  FUNCTION chk_all_product_enroll(p_tax_id IN VARCHAR2)RETURN VARCHAR2;
  /* Added this func to list products with enrollment complete for online portal*/
  FUNCTION get_products_er_online( p_user_id IN NUMBER)RETURN accounts_t PIPELINED DETERMINISTIC;
  FUNCTION skip_now_func (P_tax_id IN VARCHAR2) RETURN roles_t PIPELINED DETERMINISTIC;
  FUNCTION get_pwd_recovery(p_user_name IN VARCHAR2) RETURN user_info_t PIPELINED DETERMINISTIC;

  PROCEDURE verify_pwd_recovery(p_user_id       IN NUMBER
                             , p_user_type     IN VARCHAR2
                             , p_id_info      IN VARCHAR2
                             , x_error_status  out VARCHAR2
                             , x_error_message out VARCHAR2);


  g_dup_user_for_tax VARCHAR2(3200) :=
  'A username and password already exists for this account.'||
  'Remember that you can access all of your accounts with a single username and password. '||
  'If you cannot remember your username or password, '||
  'you may contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com.';

   g_no_tax_er VARCHAR2(3200) :=
   'The tax ID you have provided is not associated with this account number. '||
   'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com. ';
   g_no_tax_ee VARCHAR2(3200) :=
   'The social security number you have provided is not associated with this account number. '||
   'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com.  ';

   g_acct_closed_er VARCHAR2(3200) :=
   'The Account has been closed. '||
   'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com. ';


   g_invalid_SSN VARCHAR2(3200) :=
   'The social security number associated with your account is not valid, '||
   'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com for assistance with correcting your social security number  ';

    /*BroketSS0 Ticket#6834 */
   FUNCTION get_broker_to_user_info
        ( p_acc_num IN VARCHAR2
	     ,p_user_id  In Varchar2   --- 8837 12/05/2020
         ,p_broker_id IN NUMBER
         ,p_is_broker IN VARCHAr2)
   RETURN user_info_t PIPELINED DETERMINISTIC ;

    -- 9132 rprabu added to identify the broker is main or sub broker account
     Function Is_main_online_broker( p_user_id number )  Return Varchar2;

     -- Added by Jaggi #9771
     PROCEDURE UPDATE_LOGIN_INFO (P_USER_ID NUMBER ,P_IP_ADDESS IN VARCHAR2);
     -- Added By Jaggi #9731
     FUNCTION GET_USER_TYPE (P_USER_ID IN NUMBER) RETURN VARCHAR2;
      -- Added by Jaggi #9804
     PROCEDURE SAM_USERS_PWD_HISTORY (P_USER_ID IN NUMBER, P_PASSWORD IN VARCHAR2);

    -- Added by Joshi #9902
    FUNCTION get_nav_list_v2
    ( p_user_id                IN NUMBER
    ,p_account_type           IN VARCHAR2
    ,p_auth_req_id            IN NUMBER
    ,p_tax_id                 IN VARCHAR2 DEFAULT NULL)  RETURN pc_users.roles_t PIPELINED DETERMINISTIC;

    -- Added by Joshi #9902
    FUNCTION enroll_new_acct_by_ein (p_tax_id IN VARCHAR2)
    RETURN VARCHAR2;

-- Added by Jaggi #11368
   FUNCTION get_ga_to_user_info
          ( p_acc_num     IN VARCHAR2
	       ,p_user_id     IN VARCHAR2
           ,p_ga_id   IN NUMBER )
   RETURN user_info_t PIPELINED DETERMINISTIC ;

-- Added by Joshi for 12705
-- Added by Joshi for 12705
FUNCTION enable_employer_tab(p_auth_req_id IN NUMBER, p_user_id IN NUMBER)
  RETURN VARCHAR2;


END PC_USERS;



CREATE OR REPLACE EDITIONABLE PACKAGE BODY "SAMQA"."PC_USERS" IS


  PROCEDURE INSERT_USERS
    (
     p_user_name    IN VARCHAR2
    ,p_password     IN VARCHAR2
    ,p_user_type    IN VARCHAR2
    ,p_emp_reg_type IN VARCHAR2 DEFAULT NULL
    ,p_find_key     IN VARCHAR2
    ,p_locked_time  IN VARCHAR2 DEFAULT NULL
    ,p_succ_access  IN NUMBER   DEFAULT NULL
    ,p_last_login   IN VARCHAR2 DEFAULT NULL
    ,p_failed_att   IN NUMBER   DEFAULT NULL
    ,p_failed_ip    IN VARCHAR2 DEFAULT NULL
    ,p_create_pw    IN VARCHAR2 DEFAULT NULL
    ,p_change_pw    IN VARCHAR2 DEFAULT NULL
    ,p_email        IN VARCHAR2
    ,p_pw_question  IN VARCHAR2
    ,p_pw_answer    IN VARCHAR2
    ,p_confirmed_flag IN VARCHAR2 DEFAULT 'N'
    ,p_tax_id IN VARCHAR2 DEFAULT NULL
    ,x_user_id      OUT  VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
    ,p_user_id        IN  NUMBER DEFAULT NULL
    )
    IS
      setup_error  EXCEPTION;
      l_user_id    NUMBER;
      l_user_count NUMBER;
      l_sqlerrm    VARCHAR2(3200);
      l_confirmed_flag VARCHAR2(1) := 'N';
      l_tax_id     VARCHAR2(255);
      l_phone      VARCHAR2(30);
	  l_First_Name       Varchar2(255)    ;  -----9132 rprabu 04/06
      l_Middle_Name   Varchar2(1)         ;     -----9132 rprabu 04/06
      l_Last_Name       Varchar2(50)      ;  -----9132 rprabu 04/06
      L_Gender            Varchar2(1)     ;     -----9132 Rprabu 04/06
      L_Title                 Varchar2(20);  -----9132 Rprabu 04/06
      x_contact_id       Number           ;                 -----9132 Rprabu 04/06
      l_count               Number  := 0 ; -----------  9527 09/11/20202
      l_authorize_req_id  number ;
  BEGIN
      x_return_status := 'S';
      PC_LOG.LOG_ERROR('USER_CREATION','p_password '|| nvl(p_password,NULL)||' user name '||p_user_name);

      SELECT DECODE(p_user_name,NULL,'User Name cannot be null','xx')
      ||DECODE(p_user_type,NULL, 'User Type cannot be null','xx')
      ||DECODE(p_find_key,NULL, 'Account Number cannot be null','xx')
      ||DECODE(p_email,NULL,'Email cannot be null','xx')
      INTO x_error_message
      FROM DUAL;
      IF x_error_message NOT LIKE 'xx%' AND x_error_message IS NOT NULL THEN
         RAISE setup_error;
      END IF;

      x_error_message := NULL;

      x_error_message := validate_user
     ( p_tax_id      => p_tax_id
     , p_acc_num     => p_find_key
     , p_user_type   => p_user_type
     , p_emp_reg_type => p_emp_reg_type
     , p_user_name   => p_user_name
     , p_password    => p_password
     , p_user_id     => p_user_id);
       PC_LOG.LOG_ERROR('USER_CREATION','Validated User '|| x_error_message);

      IF  x_error_message IS NOT NULL THEN
         RAISE setup_error;
      END IF;
      PC_LOG.LOG_ERROR('USER_CREATION','User Name'|| p_user_name||' password question '||p_pw_question);

      IF P_emp_reg_type = 1 THEN
         l_confirmed_flag := 'Y';
      ELSE
         l_confirmed_flag := p_confirmed_flag;
      END IF;
      IF p_user_type = 'B' THEN
         l_tax_id := p_find_key;
      ELSE
        IF p_tax_id IS NULL THEN
            FOR X IN (SELECT REPLACE(P.SSN,'-') SSN, NVL(p.PHONE_DAY,p.PHONE_EVEN) PHONE
            FROM   PERSON P, ACCOUNT B, PLANS C
            WHERE  ACC_NUM = p_find_key
            AND    P.PERS_ID=B.PERS_ID
            AND    C.PLAN_CODE = B.PLAN_CODE
            AND    C.PLAN_SIGN <> 'SHA')
            LOOP
               l_tax_id := x.ssn;
               l_phone  := x.PHONE;
            END LOOP;
      ELSE
         FOR X IN (SELECT REPLACE(P.SSN,'-') SSN, NVL(p.PHONE_DAY,p.PHONE_EVEN) PHONE
            FROM   PERSON P, ACCOUNT B, PLANS C
            WHERE  P.SSN = FORMAT_SSN(p_tax_id)
            AND    P.PERS_ID=B.PERS_ID
            AND    C.PLAN_CODE = B.PLAN_CODE
            AND    C.PLAN_SIGN <> 'SHA')
            LOOP
               l_tax_id := x.ssn;
               l_phone  := x.PHONE;
            END LOOP;
         END IF;
      end if;
    INSERT INTO ONLINE_USERS
      (USER_ID
      ,USER_NAME
      ,PASSWORD
      ,USER_TYPE
      ,EMP_REG_TYPE
      ,FIND_KEY
      ,LOCKED_TIME
      ,SUCC_ACCESS
      ,LAST_LOGIN
      ,FAILED_ATT
      ,FAILED_IP
      ,CREATE_PW
      ,CHANGE_PW
      ,EMAIL
      ,PW_QUESTION
      ,PW_ANSWER
      ,CONFIRMED_FLAG
      ,TAX_ID
      ,security_setup_grace
      )
    VALUES
      (online_users_seq.NEXTVAL
      ,P_USER_NAME
      ,P_PASSWORD
      ,P_USER_TYPE
      ,P_EMP_REG_TYPE
      ,P_FIND_KEY
      ,P_LOCKED_TIME
      ,P_SUCC_ACCESS
      ,P_LAST_LOGIN
      ,P_FAILED_ATT
      ,P_FAILED_IP
      ,NVL(P_CREATE_PW,TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS'))
      ,NVL(P_CREATE_PW,TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS'))
      ,P_EMAIL
      ,P_PW_QUESTION
      ,P_PW_ANSWER
      ,l_confirmed_flag
      ,NVL(REPLACE(p_tax_id,'-'),l_tax_id)
      , TRUNC(SYSDATE)

      ) RETURNING user_id INTO x_user_id;
       --PC_LOG.LOG_ERROR('USER_CREATION','User ID '|| l_user_id);
      PC_USER_SECURITY_PKG.insert_user_security_info
      (p_user_id           => x_user_id
 				, p_otp_verified       => 'N'
				, p_verified_phone_type   => NULL
				, p_verified_phone_number => NULL );
    --  x_user_id := TO_CHAR(l_user_id);
     -- dbms_output.put_line('after inserting '||x_user_id);
      UPDATE online_enrollment
       SET   user_name = p_user_name
      WHERE  acc_num = P_FIND_KEY;
	   ------8890 04/06/2020   --- 9527 rprabu remove duplicate 06/11/2020
          IF p_user_type = 'G'    And  pc_users.Is_main_online_broker(x_user_id) = 'Y'   THEN
                         For T IN ( Select contact_name , Phone    from general_Agent where  ga_lic =p_find_key)
                         Loop
                             l_last_name                 := T.contact_name;
                             l_phone                     := T.Phone;
                           End Loop;
                     pc_contact.create_contact(p_first_name  => null
                                             ,p_last_name   => l_last_name
                                             ,p_middle_name => null
                                             ,p_title       => null
                                             ,p_gender      => null
                                             ,p_entity_id    => p_find_key
                                             ,p_phone       => l_phone
                                             ,p_fax         => null
                                             ,p_email       => p_email
                                             ,p_user_id     => x_user_id
                                             ,x_contact_id  => x_contact_id
                                             ,x_return_status  => x_return_status
                                             ,x_error_message  => x_error_message);
                       Update contact
                       set  user_id = x_user_id,  Entity_type ='MAIN_GA', Note = 'Created from Online General Agent  Registration' ,
                       contact_type ='PRIMARY'
                       WHere  contact_id =x_contact_id;
      End If;      ------ End 8890 04/06/2020


          ----- End 9132 04/06/2020
   IF p_user_type = 'B'  And   pc_users.Is_main_online_broker(x_user_id) = 'Y'    THEN
        FOR W IN ( SELECT b.first_name ,  b.middle_name  , b.last_name  , title ,  gender, PHONE_DAY
                    FROM  broker a, person b
                   WHERE  a.broker_lic =p_find_key
                   AND    a.broker_id = b.pers_id)
        LOOP
               l_middle_name         := W.middle_name;
               l_last_name           := W.last_name;
               l_first_name          := W.first_name;
               l_title               := W.title;
               l_gender              := W.gender;
               l_phone               := W.Phone_Day;
        End Loop;

              pc_contact.create_contact(p_first_name  => l_first_name
                             ,p_last_name   => l_last_name
                             ,p_middle_name => l_middle_name
                             ,p_title       => l_title
                             ,p_gender      => l_gender
                             ,p_entity_id    => p_find_key
                             ,p_phone       => l_phone
                             ,p_fax         => null
                             ,p_email       => p_email
                             ,p_user_id     => x_user_id
                             ,x_contact_id  => x_contact_id
                             ,x_return_status  => x_return_status
                             ,x_error_message  => x_error_message);
       Update contact
       set  user_id = x_user_id,  Entity_type ='MAIN_BROKER', Note = 'Created from Online Broker Registration' ,
            contact_type ='PRIMARY'
       WHere  contact_id =x_contact_id;
   End If;      ------ End 9132 04/06/2020

   -- Added by Joshi for 9902. create broker permission for new user.
  IF p_user_type = 'B' THEN
    FOR x IN (   SELECT DISTINCT B.BROKER_ID, A.ACC_ID, EP.AUTHORIZE_REQ_ID
                   FROM ACCOUNT A, BROKER B, ER_PORTAL_AUTHORIZATIONS EP
                  WHERE A.BROKER_ID = B.BROKER_ID
                    AND NVL(A.ACCOUNT_STATUS,1)  <> 4
                    AND B.BROKER_ID = EP.BROKER_ID
                    AND A.ACC_ID = EP.ACC_ID
                    AND LOWER(B.BROKER_LIC) = LOWER(P_FIND_KEY)
                    AND EP.REQUEST_STATUS = 'APPROVED' )
    LOOP

      pc_broker.insert_broker_auth_req ( P_BROKER_ID        => x.broker_id
                                        ,P_ACC_ID           => x.acc_id
                                        ,p_broker_user_id   => x_user_id
                                        ,P_USER_ID          => p_user_id
                                        ,X_AUTHORIZE_REQ_ID => l_authorize_req_id
                                        ,X_ERROR_STATUS     => x_return_status
                                        ,X_ERROR_MESSAGE    => x_error_message);

      pc_broker.create_broker_authorize(
                                      p_broker_id           => x.broker_id,
                                      p_acc_id              => x.acc_id,
                                      p_broker_user_id      => x_user_id,
                                      p_authorize_req_id    => x.authorize_req_id,
                                      p_user_id             => p_user_id,
                                      x_error_status        => x_return_status ,
                                      x_error_message       => x_error_message
                                     ) ;

    END LOOP;
   END IF;
   EXCEPTION
       WHEN setup_error THEN
        x_return_status := 'E';
     WHEN others THEN
        l_sqlerrm := sqlerrm;
        x_return_status := 'E';
        x_error_message :=  l_sqlerrm;
        --PC_LOG.LOG_ERROR('USER_CREATION',l_sqlerrm);

  END INSERT_USERS;
   PROCEDURE INSERT_CONTACT_USER
    (
     p_user_name    IN VARCHAR2
    ,p_password     IN VARCHAR2
    ,p_user_type    IN VARCHAR2
    ,p_emp_reg_type IN VARCHAR2 DEFAULT NULL
    ,p_find_key     IN VARCHAR2
    ,p_locked_time  IN VARCHAR2 DEFAULT NULL
    ,p_succ_access  IN NUMBER   DEFAULT NULL
    ,p_last_login   IN VARCHAR2 DEFAULT NULL
    ,p_failed_att   IN NUMBER   DEFAULT NULL
    ,p_failed_ip    IN VARCHAR2 DEFAULT NULL
    ,p_create_pw    IN VARCHAR2 DEFAULT NULL
    ,p_change_pw    IN VARCHAR2 DEFAULT NULL
    ,p_email        IN VARCHAR2
    ,p_pw_question  IN VARCHAR2
    ,p_pw_answer    IN VARCHAR2
    ,p_confirmed_flag IN VARCHAR2 DEFAULT 'N'
    ,p_tax_id       IN VARCHAR2 DEFAULT NULL
    ,p_first_time_pw_flag IN VARCHAR2 DEFAULT 'N'
    ,x_user_id       OUT VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
  )
  is
       setup_error  EXCEPTION;
      l_user_id    NUMBER;
      l_user_count NUMBER;
      l_sqlerrm    VARCHAR2(3200);
      l_confirmed_flag VARCHAR2(1) := 'N';
      l_tax_id     VARCHAR2(255);
  BEGIN
      x_return_status := 'S';

      SELECT DECODE(p_user_name,NULL,'User Name cannot be null','xx')
      ||DECODE(p_user_type,NULL, 'User Type cannot be null','xx')
      ||DECODE(p_find_key,NULL, 'Account Number cannot be null','xx')
      ||DECODE(p_email,NULL,'Email cannot be null','xx')
      INTO x_error_message
      FROM DUAL;
      IF x_error_message NOT LIKE 'xx%' AND x_error_message IS NOT NULL THEN
         RAISE setup_error;
      END IF;

      x_error_message := NULL;

      x_error_message := validate_user
     ( p_tax_id      => p_tax_id
     , p_acc_num     => p_find_key
     , p_user_type   => p_user_type
     , p_emp_reg_type => p_emp_reg_type
     , p_user_name   => p_user_name
     , p_password    => p_password);
       PC_LOG.LOG_ERROR('USER_CREATION','Validated User '|| x_error_message);

      IF  x_error_message IS NOT NULL THEN
         RAISE setup_error;
      END IF;
      PC_LOG.LOG_ERROR('USER_CREATION','User Name'|| p_user_name||' password question '||p_pw_question);

      IF P_emp_reg_type = 1 THEN
         l_confirmed_flag := 'Y';
      ELSE
         l_confirmed_flag := p_confirmed_flag;
      END IF;
      IF p_user_type = 'B' THEN
         l_tax_id := p_find_key;
      ELSE
        IF p_tax_id IS NULL THEN
            FOR X IN (SELECT REPLACE(P.SSN,'-') SSN
            FROM   PERSON P, ACCOUNT B, PLANS C
            WHERE  ACC_NUM = p_find_key
            AND    P.PERS_ID=B.PERS_ID
            AND    C.PLAN_CODE = B.PLAN_CODE
            AND    C.PLAN_SIGN <> 'SHA')
            LOOP
               l_tax_id := x.ssn;
            END LOOP;
         END IF;
      end if;
    INSERT INTO ONLINE_USERS
      (USER_ID
      ,USER_NAME
      ,PASSWORD
      ,USER_TYPE
      ,EMP_REG_TYPE
      ,FIND_KEY
      ,LOCKED_TIME
      ,SUCC_ACCESS
      ,LAST_LOGIN
      ,FAILED_ATT
      ,FAILED_IP
      ,CREATE_PW
      ,CHANGE_PW
      ,EMAIL
      ,PW_QUESTION
      ,PW_ANSWER
      ,CONFIRMED_FLAG
      ,TAX_ID
      ,SECURITY_SETUP_GRACE
      )
    VALUES
      (online_users_seq.NEXTVAL
      ,P_USER_NAME
      ,P_PASSWORD
      ,P_USER_TYPE
      ,P_EMP_REG_TYPE
      ,P_FIND_KEY
      ,P_LOCKED_TIME
      ,P_SUCC_ACCESS
      ,P_LAST_LOGIN
      ,P_FAILED_ATT
      ,P_FAILED_IP
      ,NVL(P_CREATE_PW,TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS'))
      ,NVL(P_CREATE_PW,TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS'))
      ,P_EMAIL
      ,P_PW_QUESTION
      ,P_PW_ANSWER
      ,l_confirmed_flag
      ,NVL(REPLACE(p_tax_id,'-'),l_tax_id)
      ,TRUNC(SYSDATE)
      ) RETURNING user_id INTO x_user_id;
       --PC_LOG.LOG_ERROR('USER_CREATION','User ID '|| l_user_id);

    --  x_user_id := TO_CHAR(l_user_id);
     -- dbms_output.put_line('after inserting '||x_user_id);
      UPDATE online_enrollment
       SET   user_name = p_user_name
      WHERE  acc_num = P_FIND_KEY;
   EXCEPTION
       WHEN setup_error THEN
        x_return_status := 'E';
     WHEN others THEN
        l_sqlerrm := sqlerrm;
        x_return_status := 'E';
        x_error_message :=  l_sqlerrm;
        --PC_LOG.LOG_ERROR('USER_CREATION',l_sqlerrm);

  END INSERT_CONTACT_USER;
    PROCEDURE UPDATE_USERS
    (
     p_user_name    IN VARCHAR2
    ,p_password     IN VARCHAR2
    ,p_user_type    IN VARCHAR2
    ,p_emp_reg_type  IN VARCHAR2 DEFAULT NULL
    ,p_find_key     IN VARCHAR2
    ,p_email        IN VARCHAR2
    ,p_pw_question  IN VARCHAR2
    ,p_pw_answer    IN VARCHAR2
    ,p_user_id      IN VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
    )
    IS
      setup_error EXCEPTION;
  BEGIN
      x_return_status := 'S';
     PC_LOG.LOG_ERROR('UPDATE_USER','in update user '||P_USER_NAME||' EMAIL '||P_EMAIL||P_USER_TYPe||P_EMP_REG_TYPE);
     PC_LOG.LOG_ERROR('UPDATE_USER','in update user '||nvl(p_password,'password not given'));
     IF p_user_name IS NOT NULL THEN
         UPDATE ONLINE_USERS
         SET
            PASSWORD      = NVL(P_PASSWORD,PASSWORD)
          ,CHANGE_PW     = to_char(sysdate,'YYYY-MM-DD HH:MI:SS')
           ,EMAIL         = NVL(P_EMAIL,EMAIL)
           ,PW_QUESTION   = DECODE(P_PW_QUESTION,NULL,PW_QUESTION,P_PW_QUESTION)
           ,PW_ANSWER     = DECODE(P_PW_ANSWER,NULL,PW_ANSWER,P_PW_ANSWER)
           ,CONFIRMED_FLAG = (CASE WHEN NVL(CONFIRMED_FLAG,'N') = 'N' AND EMP_REG_TYPE = 1 THEN 'Y'
                             ELSE CONFIRMED_FLAG END)
           ,  last_update_date = SYSDATE
            ,  last_updated_by = p_user_id
        WHERE  USER_NAME     = P_USER_NAME
        AND    USER_TYPE     = P_USER_TYPE
        AND   ((P_EMP_REG_TYPE is null ) or  (EMP_REG_TYPE  = P_EMP_REG_TYPE));
     ELSE
          PC_LOG.LOG_ERROR('UPDATE_USER','in update user ,username not given');

     END IF;
   EXCEPTION
       WHEN setup_error THEN
        x_return_status := 'E';
     WHEN others THEN
        x_return_status := 'U';
        x_error_message :=  sqlerrm;

  END UPDATE_USERS;

  PROCEDURE DELETE_USERS
    (
     p_contact_user_id     IN VARCHAR2
    ,p_user_id      IN VARCHAR2
    ,x_return_status OUT VARCHAR2
    ,x_error_message OUT VARCHAR2
    )
    IS
  BEGIN
        x_return_status := 'S';

   /*   DELETE FROM ONLINE_USERS
    WHERE
        USER_NAME     = P_USER_NAME;*/
      pc_log.log_error('DELETE_USERS ','contact user id '||p_contact_user_id);
      pc_log.log_error('DELETE_USERS ','deleting user id '||p_user_id);

      UPDATE online_users
      SET   user_status = 'D'
        ,  last_update_date = SYSDATE
          ,  last_updated_by = p_user_id
     WHERE user_id = p_contact_user_id;

     x_error_message := 'User deleted successfully';
  EXCEPTION
     WHEN others THEN
        x_return_status := 'U';
        x_error_message :=  'Error in deleting the user ';
        --sqlerrm;


  END DELETE_USERS;
  PROCEDURE delete_er_user (p_contact_user_id IN NUMBER
                       ,p_user_id       IN NUMBER
                       ,x_return_status OUT VARCHAR2
                       ,x_error_message OUT VARCHAR2)
  IS
  BEGIN
     x_return_status := 'S';
     UPDATE online_users
      SET   user_status = 'D'
        ,  last_update_date = SYSDATE
          ,  last_updated_by = p_user_id
     WHERE user_id = p_contact_user_id;

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := 'E';
       x_error_message := SQLERRM;
  END delete_er_user;
    -- Check if user account is failed attempt to login 3 times
  -- with in 30 min
  FUNCTION CHECK_USER_LOCKED
  ( p_user_name     IN VARCHAR2) return varchar2
 IS
   l_user_locked varchar2(10) := '0';
 BEGIN
   FOR X IN ( SELECT FAILED_ATT, LOCKED_TIME
               FROM  online_users
               WHERE user_name= p_user_name)
   LOOP
      IF x.FAILED_ATT >= 3 AND IS_DATE(x.LOCKED_TIME,'YYYY-MM-DD HH:MI:SS') = 'Y' THEN
           l_user_locked := TO_CHAR(trunc( (SYSDATE-TO_DATE(x.LOCKED_TIME,'YYYY-MM-DD HH:MI:SS'))*24*60));
      END IF;
   END LOOP;
   RETURN l_user_locked;
 EXCEPTION
    WHEN OTHERS THEN
       --PC_LOG.LOG_ERROR('PC_USERS.CHECK_USER_LOCKED',SQLERRM);
       RETURN '0';
 END CHECK_USER_LOCKED;
   FUNCTION get_email
  ( p_acc_num     IN VARCHAR2
  , p_acc_id      IN NUMBER
  , p_pers_id     IN NUMBER)
  return varchar2
  IS
    l_email VARCHAR2(255);
  BEGIN
     FOR X IN ( SELECT EMAIL
      FROM  online_users a,account b
      WHERE a.find_key = b.acc_num
      AND   b.acc_num = NVL(p_acc_num, b.acc_num)
      AND   b.acc_id = NVL(p_acc_id, b.acc_id)
      AND   b.pers_id = NVL(p_pers_id, b.pers_id))
    LOOP
      L_EMAIL := X.EMAIL;
    END LOOP;
      if L_EMAIL IS NULL AND p_pers_id IS NOT NULL THEN
          FOR X IN (  SELECT nvl(a.EMAIL,b.email) EMAIL
            FROM  online_users a,person b
             WHERE a.tax_id(+) = replace(b.ssn,'-')   --- rprabu 13/05/2025  INC26941 OE Notices not sent to the QB COB1428822 ( GCOB1371250)
            AND   b.pers_id = p_pers_id)
          LOOP
                L_EMAIL := X.EMAIL;

          END LOOP;
      END IF;
     RETURN l_email;
  EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END;
  FUNCTION get_email_from_taxid
  ( p_tax_id     IN VARCHAR2 )
  return varchar2
   IS
    l_email VARCHAR2(255);
  BEGIN
    FOR X IN (  SELECT EMAIL
      INTO  l_email
      FROM  online_users a
      WHERE a.tax_id = replace(p_tax_id,'-')
	    AND a.user_status = 'A'   ) -- Added by Swamy for Ticket#10978															
    LOOP
      L_EMAIL := X.email;
    END LOOP;
    IF L_EMAIL IS NULL THEN
      FOR X IN (  SELECT EMAIL
                 FROM  person a
                 WHERE a.ssn = format_ssn(p_tax_id)
                  and person_type = 'SUBSCRIBER')
       LOOP
           L_EMAIL := X.email;
       END LOOP;
    END IF;
     RETURN l_email;
  EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END get_email_from_taxid;
  FUNCTION validate_user
  ( p_tax_id       IN VARCHAR2
  , p_acc_num      IN VARCHAR2
  , p_user_type    IN VARCHAR2
  , p_emp_reg_type IN VARCHAR2
  , p_user_name    IN VARCHAR2
  , p_password     IN VARCHAR2
  , p_user_id       IN  NUMBER DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_error_message VARCHAR2(3200);
     l_plan_sign     VARCHAR2(30);
     l_user_count    NUMBER := 0;
     setup_error     EXCEPTION;
  BEGIN
     IF (p_tax_id IN ('000-00-0000','999-99-9999','123-45-6789','999-00-9999')
      OR p_tax_id LIKE '999%') THEN
         L_error_message := g_invalid_SSN;
         RAISE setup_error;

     END IF;
     PC_LOG.LOG_ERROR('USER_CREATION','tax id  '||p_tax_id);
     PC_LOG.LOG_ERROR('USER_CREATION','password in insert user '||p_password);
     IF check_user_name(p_user_name) = 'N' THEN
        L_error_message := 'The username cannot contain spaces or special characters.  It can only be letters or a combination of letters and numbers.';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
        RAISE setup_error;
     END IF;
     if p_password IS NOT NULL THEN
         IF LENGTH(p_user_name) > 24 AND p_user_name IS NOT NULL THEN
             L_error_message := 'Enter user name that is less than 24 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
             RAISE setup_error;
          END IF;

         IF LENGTH(p_user_name) < 6 AND p_user_name IS NOT NULL THEN
             L_error_message := 'Enter user name that is more than 6 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
             RAISE setup_error;

          END IF;
         IF LENGTH(p_password) < 6 AND p_password IS NOT NULL THEN
             L_error_message := 'Choose password that is more than 6 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
             RAISE setup_error;

          END IF;
         IF LENGTH(p_password) > 25 AND p_password IS NOT NULL THEN
             L_error_message := 'Choose password that is less than 24 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
             RAISE setup_error;

          END IF;
      end if;
      IF INSTR( NLS_LOWER(p_password), NLS_LOWER(p_user_name) ) != 0 THEN
           L_error_message := 'User name and Password cannot be same';
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
         RAISE setup_error;
      END IF;
      IF p_password IS NOT NULL THEN
          IF  regexp_like(p_password,'^.*[^A-Z,0-9].*$') THEN
              NULL;
          ELSE
              L_error_message := 'Password value must include a mix of letters, numbers';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
             RAISE setup_error;
          END IF;
      END IF;
      FOR X IN (SELECT plan_sign
                 FROM  account a, plans b
                WHERE  a.plan_code = b.plan_code
                AND    a.acc_num = p_acc_num)
      LOOP
         l_plan_sign := x.plan_sign;
      END LOOP;
      IF p_user_type = 'S' AND l_plan_sign = 'SHA' THEN
         /* SELECT COUNT(*)
          INTO l_user_count
          FROM online_users a, account b
          WHERE replace(tax_id,'-') = replace(p_tax_id,'-')
         -- AND   a.find_key = b.acc_num   -- commented by Joshi for INC23052/12714. A user can have only one login  across all accounts
          AND   a.user_type = 'S'
          AND   a.user_status <> 'D';*/
         -- AND   b.account_type IN ('FSA','HRA','HSA','COBRA','RB'); -- -- Added RB by Swamy for Ticket#9656 on 24/03/2021
         -- commented by Joshi for INC23052/12714. A user can have only one login  across all accounts

          SELECT COUNT(*)
            INTO l_user_count
            FROM online_users a
           WHERE replace(a.tax_id,'-') = replace(p_tax_id,'-')
             AND a.user_type = 'S'
             AND a.user_status <> 'D';

         IF l_user_count > 0 THEN

            L_error_message := g_dup_user_for_tax;
         PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
           RAISE setup_error;

         END IF;
        ELSIF   p_user_type = 'E'  AND l_plan_sign = 'SHA' AND p_emp_reg_type=2
        AND     p_user_id IS NULL THEN
         SELECT COUNT(*)
          INTO l_user_count
          FROM online_users a, account b
          WHERE  replace(tax_id,'-') = replace(p_tax_id,'-')
          AND   a.find_key = b.acc_num
          AND   a.user_type = 'E'
          --AND   a.user_status <> 'D'          -- Commented by swamy for ticket#8123
		  AND   a.user_status NOT IN ('D','I')  -- Added by swamy for ticket#8123
          AND   a.emp_reg_type= p_emp_reg_type
          AND   b.account_type IN ('FSA','HRA','HSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA','ACA','CMP','RB' ) ; -- ACA added by Swamy for Ticket#10844  -- LSA added by Swamy for Ticket#9912 -- RB Added by Jaggi #11869
         IF l_user_count > 0 THEN
            L_error_message := g_dup_user_for_tax;
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
           RAISE setup_error;
         END IF;
       END IF;

       -- Does account exist for this tax id
       IF p_user_type = 'S'  AND l_plan_sign = 'SHA' and p_acc_num IS NOT NULL THEN
         SELECT COUNT(*)
          INTO l_user_count
          FROM acc_overview_v
          WHERE replace(ssn,'-') = replace(p_tax_id,'-')
          AND   account_type IN ('FSA','HRA','HSA','COBRA','RB','LSA')   -- LSA added by Swamy for Ticket#9912 on 10/08/2021 -- Added RB by Swamy for Ticket#9656 on 24/03/2021
           AND  acc_num = p_acc_num;
         PC_LOG.LOG_ERROR('USER_CREATION','SSN '||p_tax_id);
         PC_LOG.LOG_ERROR('USER_CREATION','ACC NUM '||p_acc_num);

         IF l_user_count = 0 THEN
            L_error_message := g_no_tax_ee;
           RAISE setup_error;

         END IF;
       ELSIF   p_user_type = 'E'  AND l_plan_sign = 'SHA'  and p_acc_num IS NOT NULL THEN
         SELECT COUNT(*)
          INTO l_user_count
          FROM emp_overview_v
          WHERE replace(ein,'-') = replace(p_tax_id,'-')
          AND   account_type IN ('FSA','HRA','HSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA','ACA','CMP','RB')  -- ACA added by Swamy for Ticket#10844  -- LSA added by Swamy for Ticket#9912 on 10/08/2021
        --  AND   NVL(end_date,SYSDATE) >= SYSDATE                                                                 -- RB Added by Jaggi #11869
            AND  acc_num = p_acc_num;
         IF l_user_count = 0 THEN
            L_error_message := g_no_tax_er;
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
           RAISE setup_error;
         END IF;
         SELECT COUNT(*)
          INTO l_user_count
          FROM emp_overview_v
          WHERE replace(ein,'-') = replace(p_tax_id,'-')
          AND   account_type IN ('FSA','HRA','HSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA','ACA','CMP','RB') -- ACA added by Swamy for Ticket#10844   -- LSA added by Swamy for Ticket#9912 on 10/08/2021
          AND   NVL(end_date,SYSDATE) >= SYSDATE;                                                            -- RB Added by Jaggi #11869
          /* Sugar CRM Case..If one of the Accts is closed,users of other accts should be able to create super admins etc*/
            IF l_user_count = 0 THEN
            L_error_message := g_acct_closed_er;
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
           RAISE setup_error;
         END IF;
       END IF;

       -- User name not available
      SELECT COUNT(*)
      INTO l_user_count
      FROM online_users
      WHERE user_name = p_user_name;

      IF l_user_count > 0 THEN
         L_error_message := 'User Name '||p_user_name||' not available ';
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
         RAISE setup_error;

      END IF;
      RETURN NULL;

 EXCEPTION
    WHEN setup_error THEN
      RETURN L_error_message;

 END validate_user;
 FUNCTION check_find_key (P_TAX_ID IN VARCHAR2,P_ACC_NUM IN VARCHAR2
                      , P_USER_TYPE IN VARCHAR2 DEFAULT 'S'
                      , P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
 RETURN NUMBER
 IS
  l_user_id NUMBER;
BEGIN
 IF p_user_type = 'S' THEN
      FOR X IN ( SELECT c.user_id
                 FROM   PERSON A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.PERS_ID = B.PERS_ID
                 AND    REPLACE(A.SSN,'-') = REPLACE(P_TAX_ID,'-')
                 AND    B.ACC_NUM = P_ACC_NUM
                 AND    C.USER_TYPE = 'S'
             --    AND    C.USER_STATUS = 'A'
                 and    c.TAX_ID = replace(A.SSN,'-'))
       LOOP
             l_user_id :=x.user_id;
       END LOOP;
   END IF;
   IF p_user_type = 'E' THEN
     FOR X IN ( SELECT user_id, B.ACC_NUM
                 FROM   ENTERPRISE A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.ENTRP_ID = B.ENTRP_ID
                 AND    replace(A.ENTRP_CODE,'-') =  replace(P_TAX_ID,'-')
                 AND    B.ACC_NUM = P_ACC_NUM
                 AND    C.EMP_REG_TYPE = P_EMP_REG_TYPE
                 AND    C.USER_TYPE = 'E'
             --    AND    C.USER_STATUS = 'A'
                 and    c.TAX_ID = replacE(A.ENTRP_CODE,'-'))
       LOOP
             l_user_id :=x.user_id;
       END LOOP;
   END IF;
    IF p_user_type = 'B' THEN
        FOR X IN ( SELECT user_id
                 FROM   ONLINE_USERS C
                 WHERE  replace(C.find_key,'-') =  replace(P_TAX_ID,'-')
				 AND    C.EMP_REG_TYPE = P_EMP_REG_TYPE	  --- 8837 rprabu 14/05/2020
                 AND    C.USER_TYPE = 'B')
       LOOP
             l_user_id := x.user_id;
       END LOOP;
   END IF;

  --- 9527  04/11/2020
  IF p_user_type = 'G' THEN
    FOR X IN ( SELECT user_id
             FROM   ONLINE_USERS C
             WHERE  replace(C.find_key,'-') =  replace(P_TAX_ID,'-')
     AND    C.EMP_REG_TYPE = P_EMP_REG_TYPE
             AND    C.USER_TYPE =p_user_type)
    LOOP
         l_user_id := x.user_id;
    END LOOP;
  END IF;

   RETURN l_user_id;
END check_find_key;
 FUNCTION get_find_key (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2 DEFAULT 'S',P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
 RETURN VARCHAR2
 IS
  l_find_key VARCHAR2(30);
BEGIN
 IF p_user_type = 'S' THEN
      FOR X IN ( SELECT user_id, B.ACC_NUM
                 FROM   PERSON A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.PERS_ID = B.PERS_ID
                 AND    REPLACE(A.SSN,'-') = REPLACE(P_TAX_ID,'-')
                 AND    C.USER_TYPE = 'S'
                 AND    B.ACCOUNT_STATUS <> 4
                 AND    B.ACCOUNT_TYPE NOT IN  ('COBRA','POP')
                 and    c.TAX_ID = replace(A.SSN,'-'))
       LOOP
             l_find_key := x.ACC_NUM;
       END LOOP;
   END IF;
   IF p_user_type = 'E' THEN
     FOR X IN ( SELECT user_id, B.ACC_NUM
                 FROM   ENTERPRISE A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.ENTRP_ID = B.ENTRP_ID
                 AND    replace(A.ENTRP_CODE,'-') =  replace(P_TAX_ID,'-')
                 AND    C.EMP_REG_TYPE = P_EMP_REG_TYPE
                 AND    C.USER_TYPE = 'E'
                 AND    B.ACCOUNT_TYPE <> 'POP'
                 AND    NVL(B.END_DATE,SYSDATE) >= SYSDATE
                 and    c.TAX_ID = replacE(A.ENTRP_CODE,'-'))
       LOOP
             l_find_key := x.ACC_NUM;

       END LOOP;
   END IF;
   IF p_user_type IN ( 'B' , 'G') THEN -- Added 'G' by Joshi for 9527
      l_find_key := P_TAX_ID;
   END IF;

   RETURN l_find_key;
END get_find_key;
  FUNCTION is_user_existing (P_USER_NAME IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_count NUMBER := 0;
  BEGIN
    SELECT COUNT(*)
    INTO   l_count
    FROM online_users
    WHERE  user_name = p_user_name;

    IF l_count = 0 THEN
       RETURN 'N';
    ELSE
       RETURN 'Y';
    END IF;

  END is_user_existing;

 FUNCTION is_email_registered(P_TAX_ID IN VARCHAR2,P_email IN VARCHAR2)
   RETURN VARCHAR2
   IS
   l_count NUMBER := 0;
   BEGIN

      SELECT COUNT(*)
     INTO   l_count
     FROM online_users
     WHERE  tax_id = P_TAX_ID
     AND email = P_email;


     IF l_count = 0 THEN
        RETURN 'N';
     ELSE
        RETURN 'Y';
     END IF;

   END is_email_registered;

 FUNCTION get_user (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2 DEFAULT 'S',P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
 RETURN NUMBER
 IS
  l_user_id NUMBER;
BEGIN

 IF p_user_type = 'S' THEN
      FOR X IN ( SELECT user_id, B.ACC_NUM
                 FROM   PERSON A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.PERS_ID = B.PERS_ID
                 AND    C.USER_TYPE = 'S'
                 AND    B.ACCOUNT_TYPE <> 'POP'
                 AND    REPLACE(A.SSN,'-') = REPLACE(P_TAX_ID,'-')
                 AND    C.USER_STATUS <> 'D'
                 and    c.TAX_ID = REPLACE(A.SSN,'-'))
       LOOP
             l_user_id := x.user_id;
       END LOOP;
   END IF;
   IF p_user_type = 'E' THEN
     FOR X IN ( SELECT user_id, B.ACC_NUM
                 FROM   ENTERPRISE A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.ENTRP_ID = B.ENTRP_ID
                 AND    C.USER_TYPE = 'E'
                 AND    replace(A.ENTRP_CODE,'-') =  replace(P_TAX_ID,'-')
                 AND    C.EMP_REG_TYPE = P_EMP_REG_TYPE
                 AND    B.ACCOUNT_TYPE <> 'POP'
                 AND    C.USER_STATUS <> 'D'
                 AND    NVL(B.END_DATE,SYSDATE) >= SYSDATE
                 and    c.TAX_ID = REPLACE(A.ENTRP_CODE,'-'))
       LOOP
             l_user_id := x.user_id;

       END LOOP;
   END IF;
   IF p_user_type = 'B' THEN
     FOR X IN ( SELECT user_id
                 FROM   ONLINE_USERS C
                 WHERE  replace(C.find_key,'-') =  replace(P_TAX_ID,'-')
		         AND    C.EMP_REG_TYPE = P_EMP_REG_TYPE    ----- 8837  rprabu 07/05/2020
                 AND    C.USER_STATUS <> 'D'
                 AND    C.USER_TYPE = 'B')
       LOOP
             l_user_id := x.user_id;

       END LOOP;
   END IF;

    --------- 9527   04/11/2020
  IF p_user_type = 'G' THEN
    FOR X IN ( SELECT user_id
             FROM   ONLINE_USERS C
             WHERE  replace(C.find_key,'-') =  replace(P_TAX_ID,'-')
         AND    C.EMP_REG_TYPE = P_EMP_REG_TYPE    -----
             AND    C.USER_STATUS <> 'D'
             AND    C.USER_TYPE = p_user_type)
    LOOP
       l_user_id := x.user_id;
    END LOOP;
  END IF;
  --------- ENd 9527   04/11/2020

   RETURN l_user_id;
END get_user;
 FUNCTION get_user_name (P_USER_ID IN NUMBER)
 RETURN VARCHAR2
 IS
  l_user_name VARCHAR2(255);
BEGIN
  FOR X IN ( SELECT user_name
             FROM  ONLINE_USERS C
             WHERE  C.USER_ID = P_USER_ID)
   LOOP
         l_user_name := x.user_name;
   END LOOP;
   RETURN l_user_name;
END get_user_name;
 FUNCTION get_user_id (P_USER_NAME IN VARCHAR2)
 RETURN NUMBER
 IS
  l_user_id NUMBER;
BEGIN

  pc_log.log_error('get_user_id ','user name '||P_USER_NAME);
  FOR X IN ( SELECT USER_ID
             FROM  ONLINE_USERS C
             WHERE  C.USER_NAME = P_USER_NAME)
   LOOP
         l_user_id := x.USER_ID;
   END LOOP;

  pc_log.log_error('get_user_id ','user id '||l_user_id);

   RETURN l_user_id;
END get_user_id;
 FUNCTION get_email_from_user_id (P_USER_ID IN NUMBER)
 RETURN VARCHAR2
 IS
  l_email VARCHAR2(255);
BEGIN
  FOR X IN ( SELECT email
             FROM  ONLINE_USERS C
             WHERE  C.USER_ID = P_USER_ID)
   LOOP
         l_email := x.email;
   END LOOP;
   RETURN l_email;
END get_email_from_user_id;

FUNCTION get_user_count (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2 DEFAULT 'S',P_EMP_REG_TYPE IN NUMBER DEFAULT 2)
RETURN NUMBER
IS
  l_user_count  NUMBER;
BEGIN
 IF p_user_type = 'S' THEN
    FOR X IN ( SELECT COUNT(*) cnt
               FROM   ONLINE_USERS C
               WHERE  c.TAX_ID = REPLACE(P_TAX_ID,'-')
            --   AND    C.USER_STATUS = 'A'
               AND    EXISTS (SELECT * FROM PERSON A
                                     , ACCOUNT B
                             WHERE  A.PERS_ID = B.PERS_ID
                             AND    REPLACE(A.SSN,'-') = REPLACE(P_TAX_ID,'-')
                             AND    c.TAX_ID = REPLACE(A.SSN,'-')))
     LOOP
           l_user_count := x.cnt;
     END LOOP;
   END IF;
   IF p_user_type = 'E' THEN
     FOR X IN ( SELECT COUNT(*) cnt
               FROM   ONLINE_USERS C
               WHERE  c.TAX_ID = REPLACE(P_TAX_ID,'-')
               AND    EXISTS (SELECT * FROM ENTERPRISE A
                                     , ACCOUNT B
                             WHERE  A.ENTRP_ID = B.ENTRP_ID
                             AND    REPLACE(A.ENTRP_CODE,'-') = REPLACE(P_TAX_ID,'-')
                             AND    c.TAX_ID = REPLACE(A.ENTRP_CODE,'-')))
       LOOP
          IF x.cnt > 0 THEN
            l_user_count := x.cnt;
          END IF;
       END LOOP;
   END IF;
   RETURN l_user_count;

END get_user_count;
FUNCTION is_confirmed (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2)
RETURN VARCHAR2
IS
  l_exists VARCHAR2(1) := 'N';
BEGIN
 IF p_user_type = 'S' THEN
      FOR X IN ( SELECT COUNT(*) cnt
                 FROM   PERSON A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.PERS_ID = B.PERS_ID
                 AND    REPLACE(A.SSN,'-') = REPLACE(P_TAX_ID,'-')
               --  AND    C.USER_STATUS = 'A'
                 AND    C.CONFIRMED_FLAG = 'Y'
                 and    c.TAX_ID = REPLACE(A.ssn,'-'))
       LOOP
          IF x.cnt > 0 THEN
             l_exists := 'Y';
          END IF;
       END LOOP;
 END IF;
 IF p_user_type = 'E' THEN
     FOR X IN ( SELECT COUNT(*) cnt
                 FROM   ENTERPRISE A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.ENTRP_ID = B.ENTRP_ID
                 AND    replace(A.ENTRP_CODE,'-') =  replace(P_TAX_ID,'-')
                 AND    C.EMP_REG_TYPE = 2
                 AND    C.CONFIRMED_FLAG = 'Y'
                 AND    NVL(B.END_DATE,SYSDATE) >= SYSDATE
                 and    c.TAX_ID = REPLACE(A.ENTRP_CODE,'-'))
       LOOP
          IF x.cnt > 0 THEN
             l_exists := 'Y';
          END IF;
       END LOOP;
 END IF;
 RETURN l_exists;
END is_confirmed;
FUNCTION check_user_registered (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2)
RETURN VARCHAR2
IS
  l_exists VARCHAR2(1) := 'N';
BEGIN
 IF p_user_type = 'S' THEN
      FOR X IN ( SELECT COUNT(*) cnt
                 FROM   PERSON A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.PERS_ID = B.PERS_ID
                 AND    REPLACE(A.SSN,'-') = REPLACE(P_TAX_ID,'-')
              --   AND    C.USER_STATUS = 'A'
                 and    c.TAX_ID = REPLACE(A.ssn,'-'))
       LOOP
          IF x.cnt > 0 THEN
             l_exists := 'Y';
          END IF;
       END LOOP;
 END IF;
 IF p_user_type = 'E' THEN
     FOR X IN ( SELECT COUNT(*) cnt
                 FROM   ENTERPRISE A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.ENTRP_ID = B.ENTRP_ID
                 AND    replace(A.ENTRP_CODE,'-') =  replace(P_TAX_ID,'-')
                 AND    C.EMP_REG_TYPE = 2
                 AND    NVL(B.END_DATE,SYSDATE) >= SYSDATE
                 and    c.TAX_ID = REPLACE(A.ENTRP_CODE,'-'))
       LOOP
          IF x.cnt > 0 THEN
             l_exists := 'Y';
          END IF;
       END LOOP;
 END IF;
 RETURN l_exists;
END check_user_registered;
FUNCTION is_active_user (P_TAX_ID IN VARCHAR2,P_USER_TYPE IN VARCHAR2)
RETURN VARCHAR2
IS
  l_exists VARCHAR2(1) := 'N';
BEGIN
 IF p_user_type = 'S' THEN
      FOR X IN ( SELECT COUNT(*) cnt
                 FROM   PERSON A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.PERS_ID = B.PERS_ID
                 AND    REPLACE(A.SSN,'-') = REPLACE(P_TAX_ID,'-')
                 AND    C.USER_STATUS = 'A'
                 AND    B.ACCOUNT_STATUS <> 4
                 and    c.TAX_ID = REPLACE(A.ssn,'-'))
       LOOP
          IF x.cnt > 0 THEN
             l_exists := 'Y';
          END IF;
       END LOOP;
 END IF;
 IF p_user_type = 'E' THEN
     FOR X IN ( SELECT COUNT(*) cnt
                 FROM   ENTERPRISE A
                      , ACCOUNT B
                      , ONLINE_USERS C
                 WHERE  A.ENTRP_ID = B.ENTRP_ID
                 AND    replace(A.ENTRP_CODE,'-') =  replace(P_TAX_ID,'-')
                 AND    C.EMP_REG_TYPE = 2
                 AND    C.USER_STATUS = 'A'
                 AND    B.ACCOUNT_STATUS <> 4
                 AND    NVL(B.END_DATE,SYSDATE) >= SYSDATE
                 and    c.TAX_ID = REPLACE(A.ENTRP_CODE,'-'))
       LOOP
          IF x.cnt > 0 THEN
             l_exists := 'Y';
          END IF;
       END LOOP;
 END IF;
 RETURN l_exists;
END is_active_user;
PROCEDURE inactivate_registration ( p_acc_num IN VARCHAR2 DEFAULT NULL
                                   ,p_user_id IN NUMBER DEFAULT NULL
                                   ,p_contact_user_id IN NUMBER DEFAULT NULL
                                   ,p_user_name IN VARCHAR2 DEFAULT NULL)
IS

  l_ssn VARCHAR2(30);
  l_no_acc NUMBER;

BEGIN
  pc_log.log_error('inactivate_registration','acc num '||p_acc_num);
  pc_log.log_error('inactivate_registration','p_user_id '||p_user_id);
  pc_log.log_error('inactivate_registration','p_contact_user_id '||p_contact_user_id);
  pc_log.log_error('inactivate_registration','p_user_name '||p_user_name);

 IF p_user_name IS NOT NULL AND p_contact_user_id IS NULL THEN
     UPDATE online_users
      SET   user_status = 'I'
        ,  last_update_date = SYSDATE
          ,  last_updated_by = p_user_id
     WHERE user_name = p_user_name;
 ELSIF p_contact_user_id IS NOT NULL THEN
      UPDATE online_users
      SET   user_status = 'I'
        ,  last_update_date = SYSDATE
          ,  last_updated_by = p_user_id
     WHERE user_id = p_contact_user_id;

 ELSIF P_ACC_NUM IS NOT NULL THEN
      FOR X IN ( SELECT TAX_ID , USER_ID
                  FROM   ONLINE_USERS
                WHERE    FIND_KEY = P_ACC_NUM)
      LOOP
         SELECT COUNT(*)
         INTO   l_no_acc
         FROM   PERSON A , ACCOUNT B
         WHERE  A.PERS_ID= B.PERS_ID
         AND    A.SSN = FORMAT_SSN(X.TAX_ID);
         -- if only HSA present then inactivate the registration
         IF l_no_acc = 1 THEN
            UPDATE online_users
            SET    user_status = 'I'
                ,  last_update_date = SYSDATE
                ,  last_updated_by = p_user_id
            WHERE  user_id = x.user_id;
         END IF;


      END LOOP;
  END IF;
END inactivate_registration;


PROCEDURE reactivate_registration ( p_acc_num IN VARCHAR2 DEFAULT NULL , p_ssn IN VARCHAR2 DEFAULT NULL)
IS

  l_ssn VARCHAR2(30);
BEGIN
  IF p_acc_num IS NOT NULL AND p_ssn IS NULL THEN
     FOR X IN ( SELECT   a.ssn
                 FROM    person a, account b
        WHERE    a.pers_id = b.pers_id
        AND      b.acc_num = p_acc_num)
     LOOP
         l_ssn := x.ssn;

     END LOOP;
  ELSE
         l_ssn := p_ssn;
  END IF;

FOR X IN (SELECT A.ACC_NUM, B.BIRTH_DATE, REPLACE(B.SSN,'-') TAX_ID
    FROM   ACCOUNT A, PERSON B
    WHERE  REPLACE(B.SSN,'-') IN (select  D.TAX_ID
    from    account C, online_users D
    where   C.acc_num = d.find_key
    and     (l_ssn IS NULL OR d.tax_id = replace(l_ssn,'-'))
    and     c.account_status = 4)
    and     a.pers_id = b.pers_id
    and     a.account_status <> 4
    and     (l_ssn IS NULL OR b.ssn = l_ssn)
     AND   NOT EXISTS ( SELECT * FROM ONLINE_USERS C WHERE C.FIND_KEY = A.ACC_NUM))
 LOOP
       UPDATE ONLINE_USERS
        SET   user_status = 'A'
            ,   reactivated_date = SYSDATE
          ,   last_update_date = SYSDATE
       WHERE  tax_id = x.tax_id
       AND    user_type = 'S';
 END LOOP;
END reactivate_registration;
PROCEDURE reactivate_er_registration ( p_acc_num IN VARCHAR2 DEFAULT NULL , p_ein IN VARCHAR2 DEFAULT NULL
                                     ,p_contact_user_id IN NUMBER DEFAULT NULL, p_user_id IN  NUMBER DEFAULT NULL)
IS

  l_ein VARCHAR2(30);
BEGIN

 IF p_contact_user_id IS NOT NULL THEN
       UPDATE ONLINE_USERS
        SET   user_status = 'A'
            ,   reactivated_date = SYSDATE
          ,   last_updated_by = p_user_id
          ,   last_update_date = SYSDATE
       WHERE  user_id = p_contact_user_id
       AND    user_type IN ( 'B', 'E', 'G'  ) ;  -- 8874 12/05/2020 -- 9527 Joshi added 'G'
 ELSIF p_acc_num IS NOT NULL  THEN
  IF  p_ein IS NULL THEN
     FOR X IN ( SELECT   a.entrp_code
                 FROM    enterprise a, account b
                WHERE    a.entrp_id = b.entrp_id
                AND      b.acc_num = p_acc_num)
     LOOP
         l_ein := x.entrp_code;

     END LOOP;
  ELSE
         l_ein := p_ein;
  END IF;

      FOR X IN (SELECT  REPLACE(B.ENTRP_CODE,'-') TAX_ID
        FROM   ACCOUNT A, ENTERPRISE B
        WHERE  REPLACE(B.ENTRP_CODE,'-') IN (select  D.TAX_ID
        from    account C, online_users D
        where   C.acc_num = d.find_key
        and     (l_ein IS NULL OR d.tax_id = replace(l_ein,'-'))
        and     (c.account_status = 4 OR c.end_date IS NOT NULL ))
        and     a.entrp_id = b.entrp_id
        and     a.account_status <> 4
        and     (l_ein IS NULL OR replace(b.entrp_code,'-') = replace(l_ein,'-'))
         AND   NOT EXISTS ( SELECT * FROM ONLINE_USERS C WHERE C.FIND_KEY = A.ACC_NUM))
       LOOP
             UPDATE ONLINE_USERS
              SET   user_status = 'A'
                ,   reactivated_date = SYSDATE
                ,   last_update_date = SYSDATE
             WHERE  tax_id = x.tax_id
             AND    user_type = 'E';
       END LOOP;
  END IF;
END reactivate_er_registration;
FUNCTION validate_ee_reg(p_acc_num IN VARCHAR2
              ,p_tax_id IN VARCHAR2
              ,p_user_name   IN VARCHAR2
              ,p_birth_date  IN VARCHAR2 )
RETURN VARCHAR2
IS
   validation_error EXCEPTION;
   l_count          NUMBER := 0;
   l_error_message  VARCHAR2(3200) := 'SUCCESS';
BEGIN
    PC_LOG.LOG_ERROR('validate_ee_reg,DOB ',p_birth_date);
   PC_LOG.LOG_ERROR('validate_ee_reg,p_user_name ',p_user_name);
   PC_LOG.LOG_ERROR('validate_ee_reg,p_acc_num ',p_acc_num);
  IF p_acc_num IS NOT NULL THEN
      select count(*) into l_count
      from account where acc_num=p_acc_num;
      if l_count=0 then
         l_error_message:='We are unable to process your request as the Account Number entered does not match with what we have on record.';
         RAISE validation_error;
      end if;
   END IF;

     --We want to allow pending manual enrollments to be able to register , so updating with new code. 03/13/2018.

   /*FOR X IN (select CASE WHEN (ACCOUNT_STATUS NOT IN (1,2) OR COMPLETE_FLAG = 0)
                      AND ENROLL_FLAG = 0 THEN
                      'N'
                      WHEN  (ACCOUNT_STATUS <> 1 OR COMPLETE_FLAG = 0)
                      AND ENROLL_FLAG > 0 THEN
                                       'Y'
                      ELSE
                            'Y'
                END COMPLETE_FLAG, ACC_NUM ,
                BLOCKED_FLAG,
                BIRTH_DATE,
                ACCOUNT_TYPE,
                SSN
               from ACCOUNT_V
               where ACC_NUM=p_acc_num*/

    FOR X IN (select CASE WHEN ACCOUNT_STATUS IN (1,2,3) AND COMPLETE_FLAG = 1 THEN
          'Y'
          WHEN ACCOUNT_STATUS IN (4,5) THEN 'N'
          WHEN COMPLETE_FLAG = 0 AND ENROLL_FLAG = 0 THEN 'N'
          ELSE 'Y'
          END COMPLETE_FLAG, ACC_NUM ,
                BLOCKED_FLAG,
                BIRTH_DATE,
                ACCOUNT_TYPE,
                SSN
             from ACCOUNT_V
             where ACC_NUM=p_acc_num
   )
   LOOP


     IF x.account_type IN ('HSA','LSA') AND (x.blocked_flag = 'Y' OR x.complete_flag = 'N' ) THEN   -- LSA Added by Swamy for Ticket#9912(10164)
      l_error_message :=  'We have trouble processing your registration request at this time because your Account is in incomplete or closed, Contact Customer Service for further information';
      RAISE validation_error;
     END IF;
     IF TO_CHAR(x.birth_date,'YYYY-MM-DD') <> p_birth_date THEN
        l_error_message :=  'We are unable to process your request as the Date of Birth entered does not match with what we have in record';
        RAISE validation_error;
     END IF;
        PC_LOG.LOG_ERROR('validate_ee_reg,ssn ',p_tax_id);

        PC_LOG.LOG_ERROR('validate_ee_reg,x.ssn ',x.ssn);

     IF x.ssn <> p_tax_id THEN
        l_error_message :=  'We are unable to process your request as the Social Security Number entered does not match with what we have in record';
        RAISE validation_error;
     END IF;

     --Ticket#2487.Validate SSN w/o dashes
    IF p_tax_id <> format_ssn(p_tax_id)  THEN
        l_error_message :=  'Please re-enter your Social Security Number with  dashes XXX-XX-XXXX';
        RAISE validation_error;
     END IF;
     IF x.ssn <> p_tax_id AND TO_CHAR(x.birth_date,'YYYY-MM-DD') <> p_birth_date THEN
         l_error_message :=  ' The information you entered does not match with our records. Please try again';
         RAISE validation_error;
     END IF;
      l_count := 1;

   END LOOP;
   IF l_count = 0 THEN
        l_error_message :=  'Access has already been granted, please contact the person within your organization that has Super Administrative Access';
           RAISE validation_error;

   END IF;
        PC_LOG.LOG_ERROR('validate_ee_reg,l_error_message ',l_error_message);

   RETURN l_error_message;


EXCEPTION
   WHEN validation_error THEN
     RETURN l_error_message;
END validate_ee_reg;
FUNCTION validate_er_reg(p_acc_num IN VARCHAR2
              ,p_tax_id IN VARCHAR2
              ,p_user_name   IN VARCHAR2
              ,p_zip_code  IN VARCHAR2 )
RETURN VARCHAR2
IS
   validation_error EXCEPTION;
   l_count          NUMBER := 0;
   l_error_message  VARCHAR2(3200) := 'SUCCESS';
BEGIN
   IF p_acc_num IS NOT NULL THEN
      select count(*) into l_count from account where acc_num=p_acc_num;
      if l_count=0 then
         l_error_message:='We are unable to process your request as the Account Number entered does not match with what we have on record.';
         RAISE validation_error;
      end if;
   END IF;

   FOR X IN (select zip, ein
        from EMP_OVERVIEW_V
        where acc_num = p_acc_num )
   LOOP

     IF substr(x.zip,1,5) <> substr(p_zip_code,1,5) THEN
        l_error_message :=  'We are unable to process your request as the zip code entered does not match with what we have in record';
        RAISE validation_error;
     END IF;
     IF REPLACE(x.ein,'-') <> replace(p_tax_id,'-') THEN
        l_error_message :=  'We are unable to process your request as the Tax ID entered does not match with what we have in record';
        RAISE validation_error;
     END IF;
     l_count := 1;

   END LOOP;
   IF l_count = 0 THEN
        l_error_message :=  'We are unable to process your request as the Tax ID entered does not match with what we have in record';
   END IF;

   l_count:=0;

   SELECT COUNT(*) INTO l_count FROM ONLINE_USERS
   WHERE tax_id = REPLACE(p_tax_id,'-')
   and emp_reg_type = '2'
   AND user_type = 'E' and user_status <> 'D';

   IF l_count > 0 THEN
        l_error_message :=  'Access has already been granted, please contact the person within your organization that has Super Administrative Access';
   END IF;
   RETURN l_error_message;
EXCEPTION
   WHEN validation_error THEN
     RETURN l_error_message;
END validate_er_reg;
PROCEDURE unlock_user(p_user_name IN VARCHAR2,p_password IN VARCHAR2)
IS
 pragma autonomous_transaction;
BEGIN
  IF p_password IS NOT NULL THEN

     UPDATE online_users
     SET   locked_time = null
        ,  failed_att  = 0
     --   , blocked = 'N'
        ,  locked_reason = case when locked_reason is not null then null else locked_reason end
        ,  last_login    = TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS')
        ,  security_setup_grace = NVL(security_setup_grace,sysdate+30)
        ,  succ_access = NVL(succ_access,0)+1
    WHERE  user_name = p_user_name;

  ELSE
      UPDATE online_users
     SET   locked_time = null
        ,  failed_att  = 0
    --    ,  blocked = 'N'
        ,  locked_reason = null
        ,  last_login    = TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS')
        ,  security_setup_grace = NVL(security_setup_grace,sysdate+30)
    WHERE  user_name = p_user_name
    AND    (SYSDATE-to_date(locked_time,'YYYY-MM-DD HH24:MI:SS'))*1440 > 30
    AND    locked_reason = 'WRONG_PASSWORD';
  END IF;
  commit;

END unlock_user;

FUNCTION get_user_info
        ( p_user_name IN VARCHAR2
        , p_password  IN VARCHAR2
        , p_skip_security IN VARCHAR2 DEFAULT 'N'
        , p_referrer  IN VARCHAR2 -- anticipating for future login request
        , p_sso_user  IN VARCHAR2 ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
RETURN user_info_t PIPELINED DETERMINISTIC
IS
   e_user_exception         EXCEPTION;
   l_count                  NUMBER := 0;
   l_error_message          VARCHAR2(3200);
   l_login                  VARCHAR2(1) := 'N';
   l_loggedin               VARCHAR2(1) := 'N';

   l_skip_security          VARCHAR2(10) := 'N';
   l_no_of_registration     NUMBER := 0;
   l_record_t               user_info_row_t;
   l_user_id                NUMBER;
   l_no_accounts            NUMBER := 0;
   l_old_acct               VARCHAr2(2) := 'O';
   l_plans_enrolled          NUMBER := 0;
BEGIN

   FOR X IN (SELECT * FROM online_users
             WHERE user_name = trim(p_user_name))
   LOOP

       pc_log.log_error('PC_USERS.GET_USER_INFO','user_name '||p_user_name);
       pc_log.log_error('PC_USERS.GET_USER_INFO','password '||p_password);
       pc_log.log_error('PC_USERS.GET_USER_INFO','p_referrer '||p_referrer);


     l_count := l_count+1;
     l_record_t.user_id       := x.user_id;
     l_record_t.user_name       := p_user_name;
     l_record_t.error_status := 'S';
     l_record_t.password      := x.password;
     l_record_t.user_type     := x.user_type;
     l_record_t.emp_reg_type  := x.emp_reg_type;
     l_record_t.tax_id        := x.tax_id;
     l_record_t.confirmed_flag  := NVL(x.confirmed_flag,'N');
     l_record_t.email    := x.email;
     l_record_t.acc_num    := x.find_key;
     l_record_t.locked_reason := x.locked_reason;
     l_record_t.first_time_pw_flag := x.first_time_pw_flag;
     l_record_t.logged_in   := 'N';
     l_record_t.security_setup := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id);
     IF l_record_t.allow_login IS NULL THEN
        l_record_t.allow_login := 'Y';
     END IF;
     l_record_t.pw_reminder_qut    := x.pw_question;
     l_record_t.pw_reminder_ans    := x.pw_answer;

     l_skip_security := 'N';
     IF NVL(x.sso_user,'N') = 'Y' THEN
        l_record_t.sec_exist := 'Y';
     ELSE
        l_record_t.sec_exist := NVL(PC_USER_SECURITY_PKG.security_setting_exist(x.user_id),'N');
     END IF;
     l_record_t.locked_account := 'N';
     IF  p_skip_security = 'Y' AND p_sso_user = 'Y'
     THEN
         l_skip_security          := 'Y';
         l_record_t.sso_user        :='Y';
     ELSE
         IF x.creation_date < '10-OCT-2013' THEN
            l_skip_security          := NVL(p_skip_security,'N');
         ELSE
            l_skip_security          := 'N';
         END IF;
     END IF;

     IF  p_referrer IN ('STERLING','PASSWORD_PAGE') AND p_password IS NULL THEN
          l_error_message := '20016: Password is Required, Enter a valid password .';
          l_record_t.allow_login := 'Y';
         l_record_t.locked_account := 'Y';

          RAISE  e_user_exception;
     END IF;

     IF p_password IS NOT NULL AND p_password = x.password THEN
           unlock_user(p_user_name,p_password);
     END IF;
            pc_log.log_error('PC_USERS.GET_USER_INFO','locked_reason '||x.locked_reason);

     IF   x.locked_reason = 'WRONG_PASSWORD'
     THEN
      IF  x.failed_att >= 3 THEN
        IF (SYSDATE-to_date(X.locked_time,'YYYY-MM-DD HH24:MI:SS'))*1440 < 30 THEN
            l_error_message := '20011: Your account is temporarily suspended for 30 minutes for invalid login attempts.';
            l_record_t.allow_login := 'N';
            l_record_t.locked_account := 'Y';
            RAISE  e_user_exception;

        END IF;
      END IF;
    ELSIF x.locked_reason <>  'WRONG_PASSWORD' AND x.failed_att >= 3  THEN
          l_error_message := '20012: Your account has been locked. Please contact customer service and verify your identity to unlock your account.';
          l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

          RAISE  e_user_exception;
    END IF;

    pc_log.log_error('PC_USERS.GET_USER_INFO','password '||p_password);

    -- Added for spanish site support
     IF  p_referrer not IN ('STERLING','PASSWORD_PAGE') AND l_record_t.password <> p_password  THEN
        l_error_message := '20010: Your user name /password does not match our records, please verify your password once again';
        l_record_t.allow_login := 'N';
        l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';

          RAISE  e_user_exception;

     END IF;
     --
     IF l_record_t.password <> p_password AND p_password IS NOT NULL THEN
        l_error_message := '20010: Your user name /password does not match our records, please verify your password once again';
       l_record_t.allow_login := 'Y';
       l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
       RAISE  e_user_exception;
     END IF;

     -- check if user had confirmed registration
     IF   NVL(x.emp_reg_type,0) <> 1 AND NVL(x.confirmed_flag,'N') = 'N'
     AND  NVL(x.first_time_pw_flag,'N') = 'N'
     THEN
       l_error_message := 'We''re sorry, but you cannot access your account until you have confirmed your email. The link for this confirmation can be found in the confirmation email that was sent to the email account that you provided during registration for online access. If you have any questions, please contact us at Customer.Service@sterlingadministration.com or call 800.617.4729 during business hours';
       l_record_t.allow_login := 'N';
       l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
     -- check if user is inactive
     IF  x.user_status in ('D','I') THEN
         l_error_message := '20003: Your account is no longer active, please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
         l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

         RAISE  e_user_exception;
     END IF;
     -- check if user failed attempts more than 3 times and tried with in 30 minutes
     IF  NVL(x.failed_att,0) >= 3
     AND IS_DATE(x.locked_time,'yyyy-mm-dd hh24:mi:ss') = 'Y'
     AND 60/((SYSDATE - to_date(x.locked_time,'yyyy-mm-dd hh24:mi:ss'))*100) <= 30
     AND p_password <> x.password
     AND p_password IS NOT NULL
     THEN
       l_error_message := '20004: Your account is temporarily locked. Please try again after 30 minutes';
       l_record_t.allow_login := 'N';

       RAISE  e_user_exception;
     END IF;
     -- check if SSN has invalid ones , I mean the generic ones
     IF x.tax_id IN ( '000000000','999999999','123456789','999009999') THEN
       l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
       l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;

     -- check if SSN has invalid ones , I mean the generic ones
     -- got this info from http:--www.aila.org/content/default.aspx?docid=36839
     IF x.user_type ='S' AND (SUBSTR(x.tax_id,1,3) IN ( '000','666','900')
     OR  SUBSTR(x.tax_id,4,2) IN ( '00')
     OR  SUBSTR(x.tax_id,6,4) IN ( '0000'))
     THEN
       l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
     -- http://www.irs.gov/irm/part21/irm_21-007-013r.html
     -- Invalid EIN Prefixes are 00, 07, 08, 09, 17, 18, 19, 28, 29, 49, 69, 70, 78, 79 and 89. EINs
     -- with one of these prefixes should never be put on Master File with a TC 000.
     IF   x.user_type ='E'
     AND  SUBSTR(x.tax_id,1,2) in  ('00', '07', '08', '09', '17', '18', '19', '28'
                                  , '29', '49', '69', '70', '78', '79', '89')
     THEN
       l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
     IF x.tax_id IS NULL THEN
           l_login := 'N';
           l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
           l_record_t.allow_login := 'N';
           l_record_t.locked_account := 'Y';
           RAISE  e_user_exception;
     END IF;
     select COUNT(*)
     INTO   l_no_of_registration
     from   ONLINE_USERS
     where  (emp_reg_type IS NULL OR emp_reg_type <> 1 )
     and    tax_id=x.tax_id
     AND    user_status = 'A'
     AND    user_type = 'S'
     AND    user_type = x.user_type;

     IF l_no_of_registration > 1 THEN
       l_error_message := '20006: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
    /*
     IF  (NVL(x.first_time_pw_flag,'N') = 'Y' AND x.user_type = 'E'
    -- OR  x.password = '5f4dcc3b5aa765d61d8327deb' -- this is encrypted word for password
     )
     THEN
        l_record_t.redirect_url := 'Accounts/Accounts/ChangePassword/';  -- new view to be created for this
        l_record_t.change_password := 'Y';
        l_login := 'N';
         RAISE  e_user_exception;
     END IF;
     */
             l_record_t.skip_security :='Y';

     IF  NVL(x.failed_att,0) < 3
     AND IS_DATE(x.locked_time,'yyyy-mm-dd hh24:mi:ss') = 'Y'
     AND 60/((SYSDATE - to_date(x.locked_time,'yyyy-mm-dd hh24:mi:ss'))*100) > 30  THEN
       l_login := 'Y';
     END IF;
     IF x.user_type = 'E' AND x.emp_reg_type = 1 THEN
       IF p_password IS NULL THEN
         l_record_t.sec_exist :='Y';
        l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
        l_login := 'Y';
        RAISE  e_user_exception;
      ELSIF p_password IS NOT NULL THEN
         l_record_t.sec_exist :='Y';
        l_record_t.redirect_url := 'EnrollmentExpress/Enrollment/';
        l_login := 'Y';
        RAISE  e_user_exception;
      END IF;
    ELSE
      IF l_skip_security = 'Y' THEN
         l_record_t.sec_grace_days := 30;
         l_record_t.sec_exist := 'Y';
      ELSE

        IF p_password IS NULL THEN
           l_record_t.sec_grace_days := CASE WHEN x.security_setup_grace IS NULL AND x.creation_date < '19-OCT-2013' THEN 30
                                        WHEN x.security_setup_grace IS NULL AND x.creation_date > '19-OCT-2013' THEN 0
                                        ELSE ROUND(x.security_setup_grace-SYSDATE) END;
           l_record_t.sec_exist := NVL(PC_USER_SECURITY_PKG.security_setting_exist(x.user_id),'N');
           l_skip_security := 'N';
           IF  NVL(l_record_t.sec_grace_days,0) > 0
           AND l_record_t.sec_exist = 'N'
           THEN
              l_record_t.redirect_url := 'Accounts/Accounts/SecuritySkip/';
           ELSE
              l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
           END IF;
           l_login := 'N';
           RAISE  e_user_exception;

        END IF;




      /*  ELSE
            IF  PC_USER_SECURITY_PKG.security_setting_exist(x.user_id) = 'N'
            AND ROUND(x.security_setup_grace-SYSDATE) <= 0
            THEN
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';  -- new view to be created for this
                l_record_t.sec_grace_days := ROUND(x.security_setup_grace-SYSDATE);
                l_record_t.sec_exist := 'N';
                l_login := 'N';
                RAISE  e_user_exception;
            ELSE
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';  -- new view to be created for this
                l_record_t.sec_grace_days := ROUND(x.security_setup_grace-SYSDATE);
                l_record_t.sec_exist := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id) ;
                l_login := 'N';
                RAISE  e_user_exception;
            END IF;*/
     --   END IF;
     END IF;
    END IF;


      -- all conditions passed , letting the user login

     IF x.user_type = 'B' THEN
        l_record_t.redirect_url := 'Brokers/Detail/BrokerDashboard/';
        l_record_t.acc_num := x.find_key;
        l_record_t.account_type := '';

        FOR xX IN ( SELECT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                    FROM  broker a, person b
                   WHERE  a.broker_lic = x.find_key
                   AND    a.broker_id = b.pers_id)
        LOOP
          l_record_t.display_name := xx.name;
        END LOOP;
        l_login := 'Y';
     END IF;
       pc_log.log_error('PC_USERS.GET_USER_INFO','x.user_type '||x.user_type);

     IF x.user_type = 'S' THEN
             FOR XX IN (SELECT COUNT(*) cnt
                     FROM  account a, person b
                     WHERE b.ssn = format_ssn(x.tax_id)
                     AND   a.pers_id = b.pers_id
                     AND   a.account_type  IN ('HSA','HRA','FSA','COBRA','LSA')   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                     union
                     SELECT COUNT(*) cnt
                     FROM  account a, person b
                     WHERE b.ssn = format_ssn(x.tax_id)
                     AND   a.pers_id = b.pers_id
                     AND   a.account_type = 'COBRA'    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                     AND   account_status <> 4)
             LOOP
                l_record_t.no_of_accounts := xx.cnt;
       pc_log.log_error('PC_USERS.GET_USER_INFO','no_of_accounts '||xx.cnt);

                IF xx.cnt > 1 THEN
                   l_record_t.portfolio_account := 'Y';
                   l_login := 'Y';
                       l_record_t.redirect_url := 'Accounts/Portfolio/';

                   FOR xxx IN ( SELECT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                                FROM   person b
                               WHERE  b.ssn = format_ssn(x.tax_id))
                   LOOP
                     l_record_t.display_name := xxx.name;
                   END LOOP;
                ELSIF xx.cnt = 1 THEN

                    FOR xxx IN (
                        SELECT a.account_type, a.acc_id, a.acc_num, c.plan_sign,a.complete_flag
                            , b.first_name||' '||NVL(b.middle_name||' ','')||b.last_name name
                        FROM  account a, person b, plans c
                        WHERE b.ssn = format_ssn(x.tax_id)
                        AND   a.account_type  IN ('HSA','HRA','FSA','LSA')     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                        AND   a.pers_id = b.pers_id
                        AND   c.plan_code = a.plan_code
                        UNION
                         SELECT a.account_type, a.acc_id, a.acc_num, c.plan_sign,a.complete_flag
                            , b.first_name||' '||NVL(b.middle_name||' ','')||b.last_name name
                        FROM  account a, person b, plans c
                        WHERE b.ssn = format_ssn(x.tax_id)
                        AND   a.account_type   = 'COBRA'
                        AND   a.pers_id = b.pers_id
                        AND   c.plan_code = a.plan_code
                        AND   account_status <> 4)
                    LOOP
                         pc_log.log_error('PC_USERS.GET_USER_INFO','xxx.account_type '||xxx.account_type);

                        IF xxx.plan_sign <> 'SHA' THEN
                          l_login := 'N';
                          l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                           l_record_t.allow_login := 'N';
                         l_record_t.locked_account := 'Y';

                          RAISE  e_user_exception;
                        ELSE
                               l_record_t.portfolio_account := 'N';
                               l_record_t.acc_num := xxx.acc_num;
                               l_record_t.acc_id := xxx.acc_id;
                               l_record_t.display_name := xxx.name;

                               l_record_t.account_type := xxx.account_type;
                               IF xxx.complete_flag = 0 THEN
                                  l_record_t.redirect_url := 'AccountHolders/OnlineEnrollment/CompleteEnrollment/';
                               ELSE
                                  IF xxx.account_type = 'HSA' THEN
                                         l_record_t.redirect_url := 'AccountHolders/Detail/AccountHolderDashboard/';
                                  ELSIF  xxx.account_type = 'HRA' THEN
                                     l_record_t.redirect_url := 'HRA/AccountHolders/AccountHolderDashboard/';
                                  ELSIF  xxx.account_type = 'FSA' THEN
                                     l_record_t.redirect_url := 'FSA/AccountHolders/AccountHolderDashboard/';
                                  ELSIF  xxx.account_type = 'COBRA' THEN
                                     l_record_t.redirect_url := 'COBRA/AccountHolders/AccountHolderDashboard/';--'Accounts/Portfolio/';
                                  ELSIF  xxx.account_type = 'LSA' THEN  -- Added LSA by Swamy for Ticket#9912 on 10/08/2021
                                     l_record_t.redirect_url := 'LSA/AccountHolders/Detail/AccountHolderDashboard/';

                                  END IF;
                               END IF;
                               l_login := 'Y';
                          END IF;
                      END LOOP;
                ELSE
                  l_login := 'N';
                  l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                  l_record_t.allow_login := 'N';
                  l_record_t.locked_account := 'Y';

                  RAISE  e_user_exception;
                END IF;
             END LOOP;
     END IF;



     IF x.user_type = 'E' AND x.emp_reg_type IN (4,5,2) THEN
       --Employer Online Portal
       --We validate if it is a new user or old/existing one.
       --New user gets directed to a new URL whereas for existing users everything remains same

         IF pc_users.enroll_new_acct(X.user_id) = 'Y' THEN
             l_old_acct := 'N'; --New Acct
         ELSE
             l_old_acct := 'O' ; --Old Acct
         END IF;

     --   IF l_old_acct = 'O' THEN   --Old and existing User
             FOR XX IN (SELECT COUNT(*) cnt
                      ,sum(case when a.account_status = 3 then 1 else 0 end ) pending
                      ,sum(case when a.account_status <> 3 then 1 else 0 end ) active_count
                     FROM  account a, enterprise b
                     WHERE replace(b.entrp_code,'-') = x.tax_id
                     AND   a.entrp_id = b.entrp_id
                     AND  ( (x.emp_reg_type IN (2,5)
                     AND  a.account_type in ('HRA','HSA','FSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA'))     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                       OR (x.emp_reg_type = 4
                         AND    a.account_type in (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = x.user_id
                                           AND   B.SITE_NAV_ID = C.SITE_NAV_ID)))
                     AND   account_status <> 4)
             LOOP
                l_record_t.no_of_accounts := xx.cnt;
                IF xx.active_count > 1 THEN
                   l_record_t.portfolio_account := 'Y';
                   l_login := 'Y';
                   l_record_t.redirect_url := 'Accounts/Portfolio/';

                   FOR xxX IN ( SELECT b.name
                                FROM   enterprise b
                               WHERE   replace(b.entrp_code,'-') = replace(x.tax_id,'-'))
                   LOOP
                     l_record_t.display_name := xxx.name;
                   END LOOP;
                ELSIF xx.active_count = 0 AND XX.pending >= 1 THEN
                   l_record_t.portfolio_account := 'N';
                   l_login := 'Y';
                   l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll';

                   FOR xxX IN ( SELECT b.name
                                FROM   enterprise b
                               WHERE   replace(b.entrp_code,'-') = replace(x.tax_id,'-'))
                   LOOP
                     l_record_t.display_name := xxx.name;
                   END LOOP;

                ELSIF xx.active_count = 1 THEN
                    FOR XXX IN (
                        SELECT a.account_type, a.acc_id, a.acc_num, c.plan_sign
                            ,  b.name
                        FROM  account a, enterprise b, plans c
                        WHERE replace(b.entrp_code,'-') = x.tax_id
                        AND   c.plan_code = a.plan_code
                        AND   a.entrp_id = b.entrp_id
                        AND   a.account_status <> 3
                         AND  ( (x.emp_reg_type IN (2,5) AND  a.account_type in ('HRA','HSA','FSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA'))     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                           OR (x.emp_reg_type = 4
                         AND  a.account_type in (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = x.user_id
                                           AND   B.SITE_NAV_ID = C.SITE_NAV_ID)))
                        AND   account_status <> 4)
                    LOOP
                        IF xxx.plan_sign <> 'SHA' THEN
                          l_login := 'N';
                          l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                          l_record_t.allow_login := 'N';
                          l_record_t.locked_account := 'Y';

                          RAISE  e_user_exception;
                        ELSE
                               l_record_t.portfolio_account := 'N';
                               l_record_t.acc_num := xxx.acc_num;
                               l_record_t.acc_id := xxx.acc_id;
                               l_record_t.display_name := xxx.name;

                               l_record_t.account_type := xxx.account_type;
                               IF xxx.account_type = 'HSA' THEN
                                     l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'HRA' THEN
                                     l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'FSA' THEN
                                     l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'COBRA' THEN
                                     l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'ERISA_WRAP' THEN
                                     l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'POP' THEN
                                     l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'FORM_5500' THEN
                                     l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'LSA' THEN
                                     l_record_t.redirect_url := 'Employers/LSADetail/EmployerDashboard/';   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                               ELSE l_record_t.redirect_url := 'Accounts/Portfolio/';
                               END IF;
                               l_login := 'Y';
                        END IF;
                     END LOOP;
               --    END IF;
                   l_record_t.portfolio_account := 'N';
                   l_login := 'Y';
                ELSE
                  l_login := 'N';
                  l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                         l_record_t.allow_login := 'N';
                  l_record_t.locked_account := 'Y';

                  RAISE  e_user_exception;
                END IF;
             END LOOP;
    /*   ELSE --New User
         --If New USer has not enrolled in any plans of the associated products
         --then we show Accounts/Portfolio/newEREnroll link.
         --Else even if one product is enrolled,we show other link.
          BEGIN
            SELECT count(*)
            INTO l_plans_enrolled
            from ACCOUNT A,ENTERPRISE B
            where a.entrp_id = b.entrp_id
            and replace(b.entrp_code,'-') = replace(X.tax_id,'-')
            and account_status <> 4 --Closed accts eliminated
            and a.complete_flag = 1; --enrollment complete
           -- AND EXISTS(select * from ben_plan_enrollment_setup d --HSA plans are not covered in ben plan setup
                  --           where d.acc_id = a.acc_id);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_plans_enrolled := 0;
          END ;
  pc_log.log_error('In users', l_plans_enrolled);
         IF l_plans_enrolled = 1 THEN --Only one plan enrolled takes to Account Summary
             FOR Y IN (SELECT acc_id ,account_type
                 from ACCOUNT A,ENTERPRISE B
                 where a.entrp_id = b.entrp_id
                 and replace(b.entrp_code,'-') = replace(X.tax_id,'-')
                 and complete_flag = 1--enrollment complete
                 and account_status <> 4 --Closed accts eliminated
                -- AND EXISTS(select * from ben_plan_enrollment_setup d
                  --           where d.acc_id = a.acc_id)
                       )
             LOOP
               pc_log.log_error('In users', 'In loop'||Y.account_type);

                l_plans_enrolled := '1';
                IF Y.account_type = 'POP' THEN
                   l_login := 'Y';
                   l_record_t.portfolio_account := 'N';
                   l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'COBRA' THEN
                   l_login := 'Y';
                   l_record_t.portfolio_account := 'N';
                   l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'ERISA_WRAP' THEN
                   l_login := 'Y';
                   l_record_t.portfolio_account := 'N';
                   l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'FORM_5500' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'HSA' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                 ELSIF Y.account_type = 'HRA' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                 ELSIF Y.account_type = 'FSA' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
               END IF;
             END LOOP;
         ELSIF l_plans_enrolled > 1 THEN   --more than one plans
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := '/Accounts/Portfolio/';
         ELSIF  l_plans_enrolled = 0 THEN --No plans enrolled
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll/';
         END IF;

       END IF;--New user IF */
     END IF;
     l_user_id := x.user_id;
     IF p_skip_security = 'N' THEN
        IF (x.security_setup_grace IS NULL
           OR (x.security_setup_grace IS NOT NULL AND ROUND(x.security_setup_grace-SYSDATE) < 30))
          THEN

             l_record_t.sec_grace_days := CASE WHEN x.security_setup_grace IS NULL THEN 30
                                        ELSE ROUND(x.security_setup_grace-SYSDATE) END;
             l_login := 'Y';
             l_record_t.sec_exist := NVL(PC_USER_SECURITY_PKG.security_setting_exist(x.user_id),'N');
             IF l_record_t.sec_exist = 'N' AND p_password IS NULL
             and l_record_t.sec_grace_days > 0
             THEN
                 l_record_t.redirect_url := 'Accounts/Accounts/SecuritySkip/';  -- new view to be created for this
             ELSE
                IF p_password IS NULL THEN
                 l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';  -- new view to be created for this
                END IF;
             END IF;
        END IF;
     END IF;
     l_loggedin := l_login;

     IF p_password IS NULL THEN
        l_loggedin := 'N';
     END IF;
     IF l_login = 'Y' THEN
        FOR XX IN (
            SELECT site_key,site_image, pw_question1,pw_answer1
                 , pw_question2,pw_answer2, pw_question3,pw_answer3
                 , remember_pc,pc_insure.get_eob_status(x.tax_id) eob_status
            FROM user_security_info
            WHERE user_id = x.user_id )
        LOOP
           l_record_t.site_key      := xx.site_key;
           l_record_t.site_image    := xx.site_image;
           l_record_t.pw_question1  := pc_user_security_pkg.get_security_question(xx.pw_question1);
           l_record_t.pw_answer1    := xx.pw_answer1;
           l_record_t.pw_question2  := pc_user_security_pkg.get_security_question(xx.pw_question2);
           l_record_t.pw_answer2    := xx.pw_answer2;
           l_record_t.pw_question3  := pc_user_security_pkg.get_security_question(xx.pw_question3);
           l_record_t.pw_answer3    := xx.pw_answer3;
           l_record_t.remember_pc   := xx.remember_pc;
           l_record_t.eob_status    := xx.eob_status;
        END LOOP;
     END IF;

     l_record_t.logged_in   :=l_loggedin;
       pc_log.log_error('PC_USERS.GET_USER_INFO','redirect_url '||l_record_t.redirect_url );

     PIPE ROW(l_record_t);
   END LOOP;
   IF l_count =  0 THEN
       l_error_message := '20008: The username you have entered is not found in our records.Please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com ';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
   END IF;


EXCEPTION
   WHEN e_user_exception THEN
     l_record_t.user_name := p_user_name;
       pc_log.log_error('GET_USER_INFO','l_error_message '||l_error_message);
       pc_log.log_error('GET_USER_INFO','redirect_url '||l_record_t.redirect_url );

     IF l_error_message IS NOT NULL THEN
        l_record_t.error_message := l_error_message;
        l_record_t.error_status := 'E';
        IF l_record_t.redirect_url IS NULL THEN
           l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
           l_record_t.allow_login := 'N';

        END IF;
     END IF;
     l_loggedin := l_login;

     IF p_password IS NULL THEN
        l_loggedin := 'N';
     END IF;
     l_record_t.logged_in   :=NVL(l_loggedin,'N');

     PIPE ROW(l_record_t);

   WHEN OTHERS THEN
     l_record_t.user_name := p_user_name;
     l_record_t.error_message := SQLERRM;
     pc_log.log_error('GET_USER_INFO',' l_record_t.error_message '|| l_record_t.error_message);

     l_record_t.error_status := 'E';
     IF l_record_t.redirect_url IS NULL THEN
           l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
       l_record_t.allow_login := 'N';

     END IF;
     l_loggedin := l_login;

     l_record_t.logged_in   :=NVL(l_loggedin,'N');

     PIPE ROW(l_record_t);

END get_user_info;

FUNCTION get_user_info_v2
        ( p_user_name IN VARCHAR2
        , p_password  IN VARCHAR2
        , p_skip_security IN VARCHAR2 DEFAULT 'N'
        , p_referrer  IN VARCHAR2 -- anticipating for future login request
        , p_sso_user  IN VARCHAR2 ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
RETURN user_info_t PIPELINED DETERMINISTIC
IS
   e_user_exception         EXCEPTION;
   l_count                  NUMBER := 0;
   l_error_message          VARCHAR2(3200);
   l_login                  VARCHAR2(1) := 'N';
   l_loggedin               VARCHAR2(1) := 'N';

   l_skip_security          VARCHAR2(10) := 'N';
   l_no_of_registration     NUMBER := 0;
   l_record_t               user_info_row_t;
   l_user_id                NUMBER;
   l_no_accounts            NUMBER := 0;
   l_old_acct               VARCHAr2(2) := 'O';
   l_plans_enrolled          NUMBER := 0;
BEGIN


   FOR X IN (SELECT * FROM online_users
             WHERE user_name = trim(p_user_name))
   LOOP

       pc_log.log_error('PC_USERS.GET_USER_INFO','user_name '||p_user_name);
       pc_log.log_error('PC_USERS.GET_USER_INFO','password '||p_password);
       pc_log.log_error('PC_USERS.GET_USER_INFO','p_referrer '||p_referrer);

 pc_log.log_error('User INFO TAX IDD START',x.tax_id);
     l_count := l_count+1;
     l_record_t.user_id       := x.user_id;
     l_record_t.user_name       := p_user_name;
     l_record_t.error_status := 'S';
     l_record_t.password      := x.password;
     l_record_t.user_type     := x.user_type;
     l_record_t.emp_reg_type  := x.emp_reg_type;
     l_record_t.tax_id        := x.tax_id;
     l_record_t.confirmed_flag  := NVL(x.confirmed_flag,'N');
     l_record_t.email    := x.email;
     l_record_t.acc_num    := x.find_key;
     l_record_t.locked_reason := x.locked_reason;
     l_record_t.first_time_pw_flag := x.first_time_pw_flag;
     l_record_t.logged_in   := 'N';
--     l_record_t.security_setup := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id);
     IF l_record_t.allow_login IS NULL THEN
        l_record_t.allow_login := 'Y';
     END IF;
     l_record_t.pw_reminder_qut    := x.pw_question;
     l_record_t.pw_reminder_ans    := x.pw_answer;

     l_skip_security := 'N';
     IF NVL(x.sso_user,'N') = 'Y' THEN
        l_record_t.sec_exist := 'Y';
     ELSE
        l_record_t.sec_exist := NVL(PC_USER_SECURITY_PKG.security_setting_exist(x.user_id),'N');
     END IF;
     l_record_t.locked_account := 'N';
     l_skip_security          := 'Y';
     IF  p_sso_user = 'Y'
     THEN
         l_skip_security          := 'Y';
         l_record_t.sso_user        :='Y';
        END IF;

     IF  p_referrer IN ('STERLING','PASSWORD_PAGE') AND p_password IS NULL THEN
          l_error_message := '20016: Password is Required, Enter a valid password .';
          l_record_t.allow_login := 'N';
          l_record_t.locked_account := 'Y';

          RAISE  e_user_exception;
     END IF;
   -- check if user is blocked
     IF NVL(x.blocked,'N') = 'Y' THEN
       l_error_message := '20001: Your account is blocked, please contact customer service.';
       l_record_t.allow_login := 'N';
       l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
    IF   x.locked_reason IS NOT NULL
     THEN
          IF  x.failed_att >= 3 THEN
                IF (SYSDATE-to_date(X.locked_time,'YYYY-MM-DD HH24:MI:SS'))*1440 < 30 THEN
                    l_error_message := '20011:  Your account is temporarily suspended for 30 minutes for invalid login attempts.;;Please try again after the suspended time or contact Customer Service at 800-617-4729 during regular business hours.';
                    l_record_t.allow_login := 'N';
                    l_record_t.locked_account := 'Y';
                    RAISE  e_user_exception;
                ELSIF (SYSDATE-to_date(X.locked_time,'YYYY-MM-DD HH24:MI:SS'))*1440 >= 30 THEN
                    l_record_t.allow_login := 'Y';
                    l_record_t.locked_account := 'N';
                   unlock_user(p_user_name,p_password);

                END IF;
        ELSIF    x.failed_att < 3  AND p_password = x.password AND NVL(x.blocked,'N') = 'N'  THEN
               unlock_user(p_user_name,p_password);
        END IF;

    END IF;



    pc_log.log_error('PC_USERS.GET_USER_INFO','password '||p_password);
    pc_log.log_error('PC_USERS.GET_USER_INFO','l_record_t.password'||NVL(l_record_t.password,'XXXXXX'));

     IF NVL(l_record_t.password,'XXXXXX') <> p_password AND p_password IS NOT NULL THEN /*If password is NULL then this condition fails */
        l_error_message := '20010: Your username/password does not match our records, please try again. Your account will be locked after 3 failed attempts.';
        l_record_t.allow_login := 'N';
        l_record_t.redirect_url := 'Accounts/Login/';
        RAISE  e_user_exception;
     END IF;

     -- check if user had confirmed registration
     IF   NVL(x.emp_reg_type,0) <> 1 AND NVL(x.confirmed_flag,'N') = 'N'
     AND  NVL(x.first_time_pw_flag,'N') = 'N'
     THEN
       l_error_message := 'We''re sorry, but you cannot access your account until you have confirmed your email. The link for this confirmation can be found in the confirmation email that was sent to the email account that you provided during registration for online access. If you have any questions, please contact us at Customer.Service@sterlingadministration.com or call 800.617.4729 during business hours';
       l_record_t.allow_login := 'N';
       l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
     -- check if user is inactive
     IF  x.user_status in ('D','I') THEN
         l_error_message := '20003: Your account is no longer active, please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
         l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

         RAISE  e_user_exception;
     END IF;
     -- check if user failed attempts more than 3 times and tried with in 30 minutes
     IF  NVL(x.failed_att,0) >= 3
     AND IS_DATE(x.locked_time,'yyyy-mm-dd hh24:mi:ss') = 'Y'
     AND 60/((SYSDATE - to_date(x.locked_time,'yyyy-mm-dd hh24:mi:ss'))*100) <= 30
     AND p_password <> x.password
     AND p_password IS NOT NULL
     THEN
       l_error_message := '20004: Your account is temporarily locked. Please try again after 30 minutes';
       l_record_t.allow_login := 'N';

       RAISE  e_user_exception;
     END IF;
     -- check if SSN has invalid ones , I mean the generic ones
     IF x.tax_id IN ( '000000000','999999999','123456789','999009999') THEN
       l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
       l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;

     -- check if SSN has invalid ones , I mean the generic ones
     -- got this info from http:--www.aila.org/content/default.aspx?docid=36839
     IF x.user_type ='S' AND (SUBSTR(x.tax_id,1,3) IN ( '000','666','900')
     OR  SUBSTR(x.tax_id,4,2) IN ( '00')
     OR  SUBSTR(x.tax_id,6,4) IN ( '0000'))
     THEN
       l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
     -- http://www.irs.gov/irm/part21/irm_21-007-013r.html
     -- Invalid EIN Prefixes are 00, 07, 08, 09, 17, 18, 19, 28, 29, 49, 69, 70, 78, 79 and 89. EINs
     -- with one of these prefixes should never be put on Master File with a TC 000.
     IF   x.user_type ='E'
     AND  SUBSTR(x.tax_id,1,2) in  ('00', '07', '08', '09', '17', '18', '19', '28'
                                  , '29', '49', '69', '70', '78', '79', '89')
     THEN
       l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;
     IF x.tax_id IS NULL THEN
           l_login := 'N';
           l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
           l_record_t.allow_login := 'N';
           l_record_t.locked_account := 'Y';
           RAISE  e_user_exception;
     END IF;
     select COUNT(*)
     INTO   l_no_of_registration
     from   ONLINE_USERS
     where  (emp_reg_type IS NULL OR emp_reg_type <> 1 )
     and    tax_id=x.tax_id
     AND    user_status = 'A'
     AND    user_type = 'S'
     AND    user_type = x.user_type;

     IF l_no_of_registration > 1 THEN
       l_error_message := '20006: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
     END IF;


     IF  NVL(x.failed_att,0) >= 3
     AND IS_DATE(x.locked_time,'yyyy-mm-dd hh24:mi:ss') = 'Y'
     AND 60/((SYSDATE - to_date(x.locked_time,'yyyy-mm-dd hh24:mi:ss'))*100) > 30  THEN
       l_login := 'Y';
     END IF;
     IF x.user_type = 'E' AND x.emp_reg_type = 1 THEN
       IF p_password IS NULL THEN
         l_record_t.sec_exist :='Y';
         l_record_t.redirect_url := 'Accounts/Login/';
         l_login := 'N';
        RAISE  e_user_exception;
      ELSIF p_password IS NOT NULL THEN
         l_record_t.sec_exist :='Y';
        l_record_t.redirect_url := 'EnrollmentExpress/Enrollment/';
        l_login := 'Y';
        RAISE  e_user_exception;
      END IF;


    END IF;
    FOR xx IN (
            SELECT otp_verified,verified_phone_type, verified_phone_number ,
                   remember_pc,pc_insure.get_eob_status(x.tax_id) eob_status
              FROM user_security_info
             WHERE user_id = x.user_id )
        LOOP
           l_record_t.otp_verified      := xx.otp_verified;
           l_record_t.verified_phone_type    := xx.verified_phone_type;
            l_record_t.verified_phone_number    := xx.verified_phone_number;
            l_record_t.remember_pc    := xx.remember_pc;
           l_record_t.eob_status  := pc_insure.get_eob_status(x.tax_id);
        END LOOP;

      -- all conditions passed , letting the user login
      -- check what kind of user and set url accordingly

         IF  x.user_type In ('G',  'B'  )  THEN ----------  added by rprabu 11/06/2020 for ticket#8890
					   IF x.user_type = 'B' THEN
                                        l_record_t.redirect_url := 'Brokers/Detail/BrokerDashboard/';
                                        l_record_t.acc_num := x.find_key;
                                        l_record_t.account_type := '';
                           Else
                                      l_record_t.redirect_url := 'GA/Detail/GADashboard/';
                                    l_record_t.acc_num := x.find_key;
                                    l_record_t.account_type := '';
                          End if;
        PC_LOG.LOG_ERROR('get_user_info_v2','  (x.user_id) :  '||  x.user_id);
        PC_LOG.LOG_ERROR('get_user_info_v2',' pc_users.Is_main_online_broker(x.user_id) '||  pc_users.Is_main_online_broker(x.user_id));


     --- commented for vanitha change     rprabu ticket#9132 04/06/2020
     /*
   if pc_users.Is_main_online_broker(x.user_id) =  'Y' And x.user_type = 'B' Then    --- shavee issue 9132 02/06/2020
        FOR xX IN ( SELECT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                        ,  b.phone_day
                    FROM  broker a, person b
                   WHERE  a.broker_lic = x.find_key
                   AND    a.broker_id = b.pers_id)
        LOOP
          l_record_t.display_name := Nvl(  l_record_t.display_name, xx.name) ;
	      l_record_t.number_to_be_verified := Nvl( l_record_t.number_to_be_verified ,  xx.phone_day);
        END LOOP;
       End If;   */

         ---    rprabu ticket#9132 29/05/2020
              ---  If      l_record_t.display_name  is null then
                 FOR Z in (  select first_name  || ' ' || last_name  display_name , phone, email   from contact  where user_id = x.user_id )
                         Loop
                                  l_record_t.display_name :=   z.display_name ;
                                   --   l_record_t.email :=    z.email;   -- Commneted by Joshi #10610. emal should come from online_users always.
                                  l_record_t.number_to_be_verified :=   z.phone ;
                         End Loop;
         ----          ENd if;

        ---    rprabu ticket#9132 29/05/2020
                     FOR xx IN (
                        SELECT otp_verified,verified_phone_type, verified_phone_number , -----verified_email ,
                               remember_pc,pc_insure.get_eob_status(x.tax_id) eob_status
                          FROM user_security_info
                         WHERE user_id = x.user_id )
                    LOOP
                               l_record_t.verified_phone_number    := xx.verified_phone_number ;
                   END LOOP;


        l_login := 'Y';
     END IF;


     IF x.user_type = 'S' THEN
             FOR XX IN (SELECT COUNT(*) cnt, count(DISTINCT b.phone_day) phone_count
                     FROM  account a, person b
                     WHERE b.ssn = format_ssn(x.tax_id)
                     AND   a.pers_id = b.pers_id
                     AND   a.account_type  IN ('HSA','HRA','FSA','COBRA','RB','LSA')   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021  -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                     And nvl(a.show_account_online,'Y') = 'Y')   -- Added show_online by Swamy for Ticket#9575(Main ticket 9332) on 06/11/2020
                    -- AND   account_status <> 4)
             LOOP
                l_record_t.no_of_accounts := xx.cnt;
                pc_log.log_error('PC_USERS.GET_USER_INFO','no_of_accounts '||xx.cnt);

                IF xx.cnt > 1  THEN
                   l_record_t.portfolio_account := 'Y';
                   l_login := 'Y';
                       l_record_t.redirect_url := 'Accounts/Portfolio/';

                   FOR xxx IN ( SELECT DISTINCT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                                    ,  b.phone_day
                                FROM   person b
                               WHERE  b.ssn = format_ssn(x.tax_id))
                   LOOP
                     l_record_t.display_name := xxx.name;
                     IF xx.phone_count = 1 THEN
                        l_record_t.number_to_be_verified := xxx.phone_day;
                     END IF;
                   END LOOP;


                ELSIF xx.cnt = 1  THEN

                    FOR xxx IN (
                        SELECT a.account_type, a.acc_id, a.acc_num, c.plan_sign,a.complete_flag
                            , b.first_name||' '||NVL(b.middle_name||' ','')||b.last_name name
                            ,  b.phone_day
                        FROM  account a, person b, plans c
                        WHERE b.ssn = format_ssn(x.tax_id)
                        AND   a.account_type  IN ('HSA','HRA','FSA','COBRA','RB','LSA')  -- LSA Added by Swamy for Ticket#9912 on 10/08/2021  -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                        AND   a.pers_id = b.pers_id
                        AND   c.plan_code = a.plan_code
                        And nvl(a.show_account_online,'Y') = 'Y')
                       -- AND   account_status <> 4)
                    LOOP
                         pc_log.log_error('PC_USERS.GET_USER_INFO','xxx.account_type '||xxx.account_type);

                        IF xxx.plan_sign <> 'SHA' THEN
                          l_login := 'N';
                          l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                           l_record_t.allow_login := 'N';
                         l_record_t.locked_account := 'Y';

                          RAISE  e_user_exception;
                        ELSE
                               l_record_t.portfolio_account := 'N';
                               l_record_t.acc_num := xxx.acc_num;
                               l_record_t.acc_id := xxx.acc_id;
                               l_record_t.display_name := xxx.name;
                               l_record_t.number_to_be_verified := xxx.phone_day;

                               l_record_t.account_type := xxx.account_type;
                               IF xxx.complete_flag = 0 THEN
                                  l_record_t.redirect_url := 'AccountHolders/OnlineEnrollment/CompleteEnrollment/';
                               ELSE
                                  IF xxx.account_type = 'HSA' THEN
                                         l_record_t.redirect_url := 'AccountHolders/Detail/AccountHolderDashboard/';
                                  ELSIF  xxx.account_type = 'HRA' THEN
                                     l_record_t.redirect_url := 'HRA/AccountHolders/AccountHolderDashboard/';
                                  ELSIF  xxx.account_type = 'FSA' THEN
                                     l_record_t.redirect_url := 'FSA/AccountHolders/AccountHolderDashboard/';
                                  ELSIF  xxx.account_type = 'COBRA' THEN
                                     l_record_t.redirect_url := 'COBRA/AccountHolders/AccountHolderDashboard/';--'Accounts/Portfolio/';
                                  ELSIF  xxx.account_type = 'RB' THEN  -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                                     l_record_t.redirect_url := 'RB/AccountHolders/AccountHolderDashboard/';--'Accounts/Portfolio/';
                                  ELSIF  xxx.account_type = 'LSA' THEN  -- Added LSA by Swamy for Ticket#9912 on 10/08/2021
                                     l_record_t.redirect_url := 'LSA/AccountHolders/Detail/AccountHolderDashboard/';
                                 END IF;
                               END IF;
                               l_login := 'Y';
                          END IF;
                      END LOOP;
                ELSE
                  l_login := 'N';
                  l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                  l_record_t.allow_login := 'N';
                  l_record_t.locked_account := 'Y';

                  RAISE  e_user_exception;
                END IF;
             END LOOP;
     END IF;

     IF x.user_type = 'E' AND x.emp_reg_type IN (4,5,2) THEN
             FOR XX IN (SELECT COUNT(*) cnt
                 --     ,sum(case when a.account_status = 3 then 1 else 0 end ) pending
               ---       ,sum(case when a.account_status <> 3 then 1 else 0 end ) active_count
			,sum(case when a.account_status  In ( 3, 6 , 8, 9,10)  then 1 else 0 end ) pending       ----9141 19/08/2020 rprabu
              ,sum(case when a.account_status Not In ( 3, 6 , 8, 9,10)    then 1 else 0 end ) active_count     ----9141 19/08/2020 rprabu
		    FROM  account a, enterprise b
                     WHERE replace(b.entrp_code,'-') = x.tax_id
                     AND   a.entrp_id = b.entrp_id
                     AND  ( (x.emp_reg_type IN (2) -- Added by jaggi - role 5'id removed for #9829
                     AND  a.account_type in ('HRA','HSA','FSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA','ACA','CMP','RB')) -- ACA added by Swamy for Ticket#10844 -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                        OR (x.emp_reg_type IN (4,5)    -- Added by jaggi - role 5'id for #9829                                 -- Added by Jaggi #11689
                         AND    a.account_type in (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = x.user_id
                                           AND   B.SITE_NAV_ID = C.SITE_NAV_ID)))
                     AND   account_status <> 4)
             LOOP
                l_record_t.no_of_accounts := xx.cnt;
                IF xx.active_count > 1 THEN
                   l_record_t.portfolio_account := 'Y';
                   l_login := 'Y';
                   l_record_t.redirect_url := 'Accounts/Portfolio/';

                   FOR xxX IN ( SELECT b.name
                                FROM   enterprise b
                               WHERE   replace(b.entrp_code,'-') = replace(x.tax_id,'-'))
                   LOOP
                     l_record_t.display_name := xxx.name;
                   END LOOP;
                ELSIF xx.active_count = 0 AND XX.pending >= 1 THEN
                   l_record_t.portfolio_account := 'N';
                   l_login := 'Y';
                   l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll';

                   FOR xxX IN ( SELECT b.name,entrp_phones
                                FROM   enterprise b
                               WHERE   replace(b.entrp_code,'-') = replace(x.tax_id,'-'))
                   LOOP
                     l_record_t.display_name := xxx.name;
                      l_record_t.number_to_be_verified := xxx.entrp_phones;

                   END LOOP;

                ELSIF xx.active_count = 1 THEN
                    FOR XXX IN (
                        SELECT a.account_type, a.acc_id, a.acc_num, c.plan_sign
                            ,  b.name, b.entrp_phones
                        FROM  account a, enterprise b, plans c
                        WHERE replace(b.entrp_code,'-') = x.tax_id
                        AND   c.plan_code = a.plan_code
                        AND   a.entrp_id = b.entrp_id
                        AND   a.account_status  NOT IN (3 , 9 , 6,8,10)---9491 rprabu 15/09/2020
                        AND  ( (x.emp_reg_type IN (2)      -- Added by jaggi - role 5'id removed for #9829
                        AND  a.account_type in ('HRA','HSA','FSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA','ACA','CMP','RB'))   -- ACA added by Swamy for Ticket#10844 -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                            OR (x.emp_reg_type IN (4,5)      -- Added by jaggi - role 5'id removed for #9829                        -- RB -- Added by jaggi #11689
                         AND  a.account_type in (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = x.user_id
                                           AND   B.SITE_NAV_ID = C.SITE_NAV_ID)))
                        AND   account_status <> 4)
                    LOOP
                        IF xxx.plan_sign <> 'SHA' THEN
                          l_login := 'N';
                          l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                          l_record_t.allow_login := 'N';
                          l_record_t.locked_account := 'Y';

                          RAISE  e_user_exception;
                        ELSE
                               l_record_t.portfolio_account := 'N';
                               l_record_t.acc_num := xxx.acc_num;
                               l_record_t.acc_id := xxx.acc_id;
                               l_record_t.display_name := xxx.name;
                               l_record_t.number_to_be_verified := xxx.entrp_phones;


                                   pc_log.log_error('PC_USERS.GET_USER_INFO_V2','xxx.15/09 : '||xxx.account_type|| l_record_t.redirect_url );

                               l_record_t.account_type := xxx.account_type;
                                   IF xxx.account_type = 'HSA' THEN
                                     l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'HRA' THEN
                                     l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'FSA' THEN
                                     l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'COBRA' THEN
                                     l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'ERISA_WRAP' THEN
                                 pc_log.log_error('PC_USERS.GET_USER_INFO_V2','ERISA_WRAP : 15/09 : '||xxx.account_type|| l_record_t.redirect_url );
                                     l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'POP' THEN
                                               pc_log.log_error('PC_USERS.GET_USER_INFO_V2','POP  : 15/09 : '||xxx.account_type|| l_record_t.redirect_url );
                                     l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'FORM_5500' THEN
                                     l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'LSA' THEN
                                     l_record_t.redirect_url := 'Employers/LSADetail/EmployerDashboard/';   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                               ELSIF  xxx.account_type = 'ACA' THEN
                                     l_record_t.redirect_url := 'ACA/Employers/EmployerDashboard/';   -- ACA added by Swamy for Ticket#10844
                               ELSIF  xxx.account_type = 'CMP' THEN
                                     l_record_t.redirect_url := 'CMP/Employers/EmployerDashboard/';   -- CMP added by jaggi for Ticket#11218
                               ELSIF  xxx.account_type = 'RB' THEN
                                     l_record_t.redirect_url := 'RB/Employers/EmployerDashboard/';    -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                               ELSE l_record_t.redirect_url := 'Accounts/Portfolio/';                 -- Added by jaggi #11689
                               END IF;
                               l_login := 'Y';
                        END IF;
                     END LOOP;
               --    END IF;
                     FOR U in ( select phone from contact where user_id = x.user_id)
                     loop
                         l_record_t.number_to_be_verified := u.phone;
                     end loop;
                   l_record_t.portfolio_account := 'N';
                   l_login := 'Y';
                ELSE
                  l_login := 'N';
                  l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                         l_record_t.allow_login := 'N';
                  l_record_t.locked_account := 'Y';

                  RAISE  e_user_exception;
                END IF;
             END LOOP;

     END IF;
     l_user_id := x.user_id;

     l_loggedin := 'N';

     IF p_password IS NULL THEN
        l_loggedin := 'N';
     END IF;
     l_record_t.show_modal_window  := PC_USER_SECURITY_PKG.show_phone_update_modal(x.user_id);
     l_record_t.logged_in   :=l_loggedin;
       pc_log.log_error('PC_USERS.GET_USER_INFO','redirect_url '||l_record_t.redirect_url );

	-- Added by Joshi for 6596. page should be shown for individual.
    l_record_t.show_td_ameritrade_page := 'N';
    FOR Y IN ( select p.entrp_id
                from account a, person p, online_users o
                where o.find_key= a.acc_num
                and o.user_type = 'S'
                and  a.account_type= 'HSA'
                and a.pers_id = p.pers_id
                and o.user_id = x.user_id)
    LOOP
        IF y.entrp_id is NULL THEN
          l_record_t.show_td_ameritrade_page := 'Y';
        ELSE
          l_record_t.show_td_ameritrade_page := 'N';
        END IF;
    END LOOP;
	-- code ends here 6596.

     PIPE ROW(l_record_t);
   END LOOP;

    pc_log.log_error('PC_USERS.GET_USER_INFO','l_count '||l_count );
   IF l_count =  0 THEN
       l_error_message := '20008: Your username/password does not match our records, please try again. Your account will be locked after 3 failed attempts.';
       l_record_t.allow_login := 'N';
         l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
   END IF;


EXCEPTION
   WHEN e_user_exception THEN
     l_record_t.user_name := p_user_name;
       pc_log.log_error('GET_USER_INFO','l_error_message '||l_error_message);
       pc_log.log_error('GET_USER_INFO','redirect_url '||l_record_t.redirect_url );
           --l_record_t.allow_login := 'N';
          -- l_record_t.tax_id := null;
           -- l_record_t.password := null;

     IF l_error_message IS NOT NULL THEN
        l_record_t.error_message := l_error_message;
        l_record_t.error_status := 'E';
        IF l_record_t.redirect_url IS NULL THEN
           l_record_t.redirect_url := 'Accounts/Login/';

        END IF;
     END IF;
     l_loggedin := l_login;

pc_log.log_error('User INFO TAX IDD  END..2',l_record_t.tax_id);

     IF p_password IS NULL THEN
        l_loggedin := 'N';
     END IF;
     l_record_t.logged_in   :=NVL(l_loggedin,'N');
pc_log.log_error('User INFO TAX IDD  END..3',l_record_t.tax_id);

     PIPE ROW(l_record_t);

   WHEN OTHERS THEN
     l_record_t.user_name := p_user_name;
     l_record_t.error_message := SQLERRM;
     pc_log.log_error('GET_USER_INFO',' l_record_t.error_message '|| l_record_t.error_message);
     l_record_t.error_message :=  '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';

     l_record_t.error_status := 'E';
     IF l_record_t.redirect_url IS NULL THEN
           l_record_t.redirect_url := 'Accounts/Login/';
       l_record_t.allow_login := 'N';

     END IF;
     l_loggedin := l_login;

     l_record_t.logged_in   :=NVL(l_loggedin,'N');
          l_record_t.tax_id := null;
            l_record_t.password := null;

     PIPE ROW(l_record_t);

END get_user_info_v2;
FUNCTION get_user_info_by_uname(p_user_name IN VARCHAR2) RETURN user_info_t PIPELINED DETERMINISTIC
IS
   e_user_exception         EXCEPTION;
   l_count                  NUMBER := 0;
   l_error_message          VARCHAR2(3200);
   l_login                  VARCHAR2(1) := 'N';
   l_loggedin               VARCHAR2(1) := 'N';
   l_skip_security          VARCHAR2(10) := 'N';
   l_no_of_registration     NUMBER := 0;
   l_record_t               user_info_row_t;
   l_user_id                NUMBER;
   l_no_accounts            NUMBER := 0;
BEGIN

   FOR X IN (SELECT *
               FROM online_users
              WHERE user_name = trim(p_user_name))
   LOOP

     pc_log.log_error('GET_USER_INFO_BY_UNAME','user_name '||p_user_name);
     l_count := 1;
     l_record_t.user_id       := x.user_id;
     l_record_t.user_name       := p_user_name;
     l_record_t.error_status := 'S';
     l_record_t.password      := x.password;
     l_record_t.user_type     := x.user_type;
     l_record_t.emp_reg_type  := x.emp_reg_type;
     l_record_t.tax_id        := x.tax_id;
     l_record_t.confirmed_flag  := NVL(x.confirmed_flag,'N');
     l_record_t.email    := x.email;
     l_record_t.acc_num    := x.find_key;
     l_record_t.locked_reason := x.locked_reason;
     l_record_t.first_time_pw_flag := x.first_time_pw_flag;
     l_record_t.logged_in   := 'N';
--     l_record_t.security_setup := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id);
     IF l_record_t.allow_login IS NULL THEN
        l_record_t.allow_login := 'Y';
     END IF;
     l_record_t.pw_reminder_qut    := x.pw_question;
     l_record_t.pw_reminder_ans    := x.pw_answer;
                   l_record_t.portfolio_account := 'N';

     IF l_record_t.allow_login IS NULL THEN
       l_record_t.allow_login := 'Y';
     END IF;

     l_record_t.pw_reminder_qut    := x.pw_question;
     l_record_t.pw_reminder_ans    := x.pw_answer;

     l_skip_security := 'N';

     IF NVL(x.sso_user,'N') = 'Y' THEN
        l_record_t.sec_exist := 'Y';
     ELSE
        l_record_t.sec_exist := NVL(pc_user_security_pkg.security_setting_exist(x.user_id),'N');
     END IF;
     l_record_t.locked_account := 'N';
     l_record_t.status := CASE WHEN x.user_status = 'A'THEN 'Active' WHEN x.user_status = 'I' THEN 'Inactive' ELSE Null END;  -- Added by Jaggi #11090 on 05/10/2022

     -- all conditions passed , letting the user login

     IF x.user_type = 'B' THEN
       l_record_t.redirect_url := 'Brokers/Detail/BrokerDashboard/';
       l_record_t.acc_num := x.find_key;
       l_record_t.account_type := '';

       FOR xx IN ( SELECT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                     FROM  broker a, person b
                    WHERE  a.broker_lic = x.find_key
                    AND    a.broker_id = b.pers_id)
       LOOP
         l_record_t.display_name := xx.name;
       END LOOP;
       l_login := 'Y';
     END IF;

     -- Start Added by Swamy for Ticket#9559 on 06/11/2020
	 IF x.user_type = 'G' THEN
       l_record_t.redirect_url := 'GA/Detail/GADashboard/';
       l_record_t.acc_num := x.find_key;
       l_record_t.account_type := '';
       l_login := 'Y';
     END IF;
	 -- End of Addition by Swamy for Ticket#9559

     pc_log.log_error('GET_USER_INFO_BY_UNAME','x.user_type '||x.user_type);

     IF x.user_type = 'S' THEN
     FOR xx IN (SELECT COUNT(*) cnt
                  FROM  account a, person b
                 WHERE b.ssn = format_ssn(x.tax_id)
                   AND   a.pers_id = b.pers_id
                   AND   a.account_type  IN ('HSA','HRA','FSA','COBRA','LSA')    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                   AND NVL(a.show_account_online,'Y') = 'Y'  -- Added show_online by Swamy for Ticket#9839(Main ticket 9332) on 08/04/2021
                 )

             LOOP
               l_record_t.no_of_accounts := xx.cnt;
               pc_log.log_error('GET_USER_INFO_BY_UNAME','no_of_accounts '||xx.cnt);

               IF xx.cnt > 1 THEN
                 l_record_t.portfolio_account := 'Y';
                 l_login := 'Y';
                 l_record_t.redirect_url := 'Accounts/Portfolio/';

                 FOR xxx IN ( SELECT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                                FROM   person b
                               WHERE  b.ssn = format_ssn(x.tax_id))
                 LOOP
                   l_record_t.display_name := xxx.name;
                 END LOOP;
                 ELSIF xx.cnt = 1 THEN

                   FOR xxx IN(SELECT a.account_type,
                                     a.acc_id,
                                     a.acc_num,
                                     c.plan_sign,
                                     a.complete_flag,
                                     b.first_name||' '||NVL(b.middle_name||' ','')||b.last_name name
                                FROM  account a, person b, plans c
                               WHERE b.ssn = format_ssn(x.tax_id)
                               AND   a.account_type  IN ('HSA','HRA','FSA','COBRA','LSA', 'ACA' )     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                               AND   a.pers_id = b.pers_id
                               AND   c.plan_code = a.plan_code
                               AND NVL(a.show_account_online,'Y') = 'Y'   -- Added by Swamy for Ticket#Prodissue
                               )

                    LOOP
                      pc_log.log_error('GET_USER_INFO_BY_UNAME','xxx.account_type '||xxx.account_type);

                      IF xxx.plan_sign <> 'SHA' THEN
                        l_login := 'N';
                        l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';

                        RAISE  e_user_exception;
                      ELSE
                        l_record_t.portfolio_account := 'N';
                        l_record_t.acc_num := xxx.acc_num;
                        l_record_t.acc_id := xxx.acc_id;
                        l_record_t.display_name := xxx.name;
                l_record_t.account_type := xxx.account_type;

                    IF xxx.complete_flag = 0 THEN
                            l_record_t.redirect_url := 'AccountHolders/OnlineEnrollment/CompleteEnrollment/';
                    ELSE
                        IF xxx.account_type = 'HSA' THEN
                          l_record_t.redirect_url := 'AccountHolders/Detail/AccountHolderDashboard/';
                        ELSIF  xxx.account_type = 'HRA' THEN
                          l_record_t.redirect_url := 'HRA/AccountHolders/AccountHolderDashboard/';
                        ELSIF  xxx.account_type = 'FSA' THEN
                          l_record_t.redirect_url := 'FSA/AccountHolders/AccountHolderDashboard/';
                        ELSIF  xxx.account_type = 'COBRA' THEN
                          l_record_t.redirect_url := 'COBRA/AccountHolders/AccountHolderDashboard/';
                        ELSIF  xxx.account_type = 'LSA' THEN  -- Added LSA by Swamy for Ticket#9912 on 10/08/2021
                          l_record_t.redirect_url := 'LSA/AccountHolders/Detail/AccountHolderDashboard/';

                        END IF;
                     END IF;
                        l_login := 'Y';
                        END IF;
                      END LOOP;
                ELSE
                  l_login := 'N';
                  l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                  l_record_t.allow_login := 'N';
                  l_record_t.locked_account := 'Y';

                  RAISE  e_user_exception;
                END IF;
     END LOOP;
     END IF;

  FOR xx IN (
            SELECT otp_verified,verified_phone_type, verified_phone_number ,
                   remember_pc,pc_insure.get_eob_status(x.tax_id) eob_status
              FROM user_security_info
             WHERE user_id = x.user_id )
        LOOP
           l_record_t.otp_verified      := xx.otp_verified;
           l_record_t.verified_phone_type    := xx.verified_phone_type;
            l_record_t.verified_phone_number    := xx.verified_phone_number;
            l_record_t.remember_pc    := xx.remember_pc;
           l_record_t.eob_status  := pc_insure.get_eob_status(x.tax_id);
        END LOOP;
    IF x.user_type = 'E' AND x.emp_reg_type IN (4,5,2) THEN
             FOR XX IN (SELECT COUNT(*) cnt
                      ,sum(case when a.account_status = 3 then 1 else 0 end ) pending
                      ,sum(case when a.account_status <> 3 then 1 else 0 end ) active_count
                     FROM  account a, enterprise b
                     WHERE replace(b.entrp_code,'-') = x.tax_id
                     AND   a.entrp_id = b.entrp_id
                     AND  ( (x.emp_reg_type IN (2,5)
                     AND  a.account_type in ('HRA','HSA','FSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA', 'ACA', 'CMP','RB'))    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021 --11744  added ACA/CMP/RB Joshi
                       OR (x.emp_reg_type = 4
                         AND    a.account_type in (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = x.user_id
                                           AND   B.SITE_NAV_ID = C.SITE_NAV_ID)))
                     AND   account_status <> 4)
             LOOP 
                l_record_t.no_of_accounts := xx.cnt;
                IF xx.active_count > 1 THEN
                   l_record_t.portfolio_account := 'Y';
                   l_login := 'Y';
                   l_record_t.redirect_url := 'Accounts/Portfolio/';

                   FOR xxX IN ( SELECT b.name
                                FROM   enterprise b
                               WHERE   replace(b.entrp_code,'-') = replace(x.tax_id,'-'))
                   LOOP
                     l_record_t.display_name := xxx.name;
                   END LOOP;
                ELSIF xx.active_count = 0 AND XX.pending >= 1 THEN
                   l_record_t.portfolio_account := 'N';
                   l_login := 'Y';
                   l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll';

                   FOR xxX IN ( SELECT b.name,entrp_phones
                                FROM   enterprise b
                               WHERE   replace(b.entrp_code,'-') = replace(x.tax_id,'-'))
                   LOOP
                     l_record_t.display_name := xxx.name;
                      l_record_t.number_to_be_verified := xxx.entrp_phones;

                   END LOOP;

                ELSIF xx.active_count = 1 THEN

                                pc_log.log_error('GET_USER_INFO_BY_UNAME','get_user_info_v2  active_count :   '||xx.active_count);
                    FOR XXX IN (
                        SELECT a.account_type, a.acc_id, a.acc_num, c.plan_sign
                            ,  b.name, b.entrp_phones
                        FROM  account a, enterprise b, plans c
                        WHERE replace(b.entrp_code,'-') = x.tax_id
                        AND   c.plan_code = a.plan_code
                        AND   a.entrp_id = b.entrp_id
                        AND   a.account_status <> 3
                        AND  ( (x.emp_reg_type IN (2,5)
                        AND  a.account_type in ('HRA','HSA','FSA','COBRA','ERISA_WRAP','POP','FORM_5500','LSA', 'ACA', 'CMP','RB'))    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021--11744  added ACA/CMP/RB Joshi
                           OR (x.emp_reg_type = 4
                         AND  a.account_type in (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = x.user_id
                                           AND   B.SITE_NAV_ID = C.SITE_NAV_ID)))
                        AND   account_status <> 4
                        )
                    LOOP
                        IF xxx.plan_sign <> 'SHA' THEN
                          l_login := 'N';
                          l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                          l_record_t.allow_login := 'N';
                          l_record_t.locked_account := 'Y';

                          RAISE  e_user_exception;
                        ELSE
                               l_record_t.portfolio_account := 'N';
                               l_record_t.acc_num := xxx.acc_num;
                               l_record_t.acc_id := xxx.acc_id;
                               l_record_t.display_name := xxx.name;
                               l_record_t.number_to_be_verified := xxx.entrp_phones;

                               l_record_t.account_type := xxx.account_type;
                               IF xxx.account_type = 'HSA' THEN
                                     l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'HRA' THEN
                                     l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'FSA' THEN
                                     l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'COBRA' THEN
                                     l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'ERISA_WRAP' THEN
                                     l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'POP' THEN
                                     l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'FORM_5500' THEN
                                     l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                               ELSIF  xxx.account_type = 'LSA' THEN
                                     l_record_t.redirect_url := 'Employers/LSADetail/EmployerDashboard/';   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                               ELSIF  xxx.account_type = 'ACA' THEN
                                     l_record_t.redirect_url := 'ACA/Employers/EmployerDashboard';   --11744  added ACA/CMP/RB Joshi
                               ELSIF  xxx.account_type = 'CMP' THEN
                                     l_record_t.redirect_url := 'CMP/Employers/EmployerDashboard';  --11744  added ACA/CMP/RB Joshi
                               ELSIF  xxx.account_type = 'RB' THEN
                                     l_record_t.redirect_url := 'RB/Employers/EmployerDashboard';     --11744  added ACA/CMP/RB Joshi
                               ELSE l_record_t.redirect_url := 'Accounts/Portfolio/';
                               END IF;
                               l_login := 'Y';
                        END IF;
                     END LOOP;
               --    END IF;
                     FOR U in ( select phone from contact where user_id = x.user_id)
                     loop
                         l_record_t.number_to_be_verified := u.phone;
                     end loop;
                   l_record_t.portfolio_account := 'N';
                   l_login := 'Y';
                ELSE
                  l_login := 'N';
                  l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com';
                         l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';

                  RAISE  e_user_exception;
                END IF;
             END LOOP;

     END IF;
   l_user_id := x.user_id;
   l_loggedin := l_login;

     l_record_t.portfolio_account   :=nvl(l_record_t.portfolio_account,'N');

     l_record_t.logged_in   :=l_loggedin;
       pc_log.log_error('GET_USER_INFO_BY_UNAME','redirect_url '||l_record_t.redirect_url );
     l_record_t.show_modal_window  := PC_USER_SECURITY_PKG.show_phone_update_modal(x.user_id);

     PIPE ROW(l_record_t);
   END LOOP;

   IF l_count =  0 THEN
       l_error_message := '20008: The username you have entered is not found in our records. Please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com ';
       l_record_t.allow_login := 'N';
       l_record_t.locked_account := 'Y';

       RAISE  e_user_exception;
   END IF;


EXCEPTION

  WHEN e_user_exception THEN
    l_record_t.user_name := p_user_name;
    pc_log.log_error('GET_USER_INFO_BY_UNAME','l_error_message '||l_error_message);
    pc_log.log_error('GET_USER_INFO_BY_UNAME','redirect_url '||l_record_t.redirect_url );

  IF l_error_message IS NOT NULL THEN
     l_record_t.error_message := l_error_message;
     l_record_t.error_status := 'E';

     IF l_record_t.redirect_url IS NULL THEN
        l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
        l_record_t.allow_login := 'N';

     END IF;
  END IF;
  l_loggedin := l_login;

  l_record_t.logged_in := NVL(l_loggedin,'N');
  PIPE ROW(l_record_t);

 WHEN OTHERS THEN
   l_record_t.user_name := p_user_name;
   l_record_t.error_message := SQLERRM;
   pc_log.log_error('GET_USER_INFO_BY_UNAME',' l_record_t.error_message '|| l_record_t.error_message);

   l_record_t.error_status := 'E';

   IF l_record_t.redirect_url IS NULL THEN
     l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
     l_record_t.allow_login := 'N';

   END IF;
     l_loggedin := l_login;

     l_record_t.logged_in   :=NVL(l_loggedin,'N');

   PIPE ROW(l_record_t);

END get_user_info_by_uname;

PROCEDURE lock_user (p_user_id IN NUMBER, p_lock_reason IN VARCHAR2,p_ip_address IN VARCHAR2)
IS
l_blk VARCHAR2(2);
BEGIN

    pc_log.log_error('lock_user','user id '||p_user_id||' lock reason '||p_lock_reason);
   IF p_lock_reason = 'WRONG_PASSWORD' THEN
    UPDATE online_users
     SET   locked_time = to_char(sysdate,'YYYY-MM-DD HH24:MI:SS')
        ,  failed_att  = NVL(failed_att,0)+1
        ,  failed_ip   = p_ip_address
        ,  locked_reason = p_lock_reason
    WHERE  user_id = p_user_id
    AND    (emp_reg_type is null or emp_reg_type <> 1);
   ELSE
    UPDATE online_users
     SET   locked_time = to_char(sysdate,'YYYY-MM-DD HH24:MI:SS')
        ,  locked_reason = p_lock_reason
        ,  failed_ip   = p_ip_address
        ,  failed_att  = NVL(failed_att,0)+1
    WHERE  user_id = p_user_id
    AND    (emp_reg_type is null or emp_reg_type <> 1);

   END IF;
     /*Block the user on 3 invalid attempts */
     -- Vanitha commented it as it doesnt make sense
   /*FOR X IN ( SELECT failed_att FROM online_users
                 WHERE user_id = p_user_id)
   LOOP
      IF x.failed_att = 3 THEN
        UPDATE online_users
        SET blocked = 'Y'
        WHERE user_id = p_user_id;
      END IF;
    END LOOP;*/

 END lock_user;


 PROCEDURE lock_user_with_ssn (p_ssn IN VARCHAR2, p_lock_reason IN VARCHAR2,p_ip_address IN VARCHAR2)
 IS
 BEGIN

    UPDATE online_users
     SET   locked_time = to_char(sysdate,'YYYY-MM-DD HH24:MI:SS')
        ,  locked_reason = p_lock_reason
        ,  failed_ip   = p_ip_address
        ,  failed_att  = failed_att+1
    WHERE  tax_id = replace(p_ssn,'-');

 END lock_user_with_ssn;
 PROCEDURE create_role_entries (p_contact_user_id IN NUMBER
                              , p_role_entries    IN PC_ONLINE_ENROLLMENT.VARCHAR2_TBL
                              , p_user_id         IN NUMBER
                              , p_role_id         IN NUMBER
                              , p_authorize_req_id IN NUMBER
                              , x_return_status OUT VARCHAR2
                              , x_error_message OUT VARCHAR2)
 IS
 BEGIN
   x_return_status := 'S';

   pc_log.log_error('pc_users.create_role_entries: p_contact_user_id: ', p_contact_user_id );
   pc_log.log_error('pc_users.create_role_entries: p_authorize_req_id: ', p_authorize_req_id );

   -- Added by Joshi for 9902.
   IF p_authorize_req_id IS NULL THEN
     DELETE FROM USER_ROLE_ENTRIES
      WHERE user_id = p_contact_user_id  AND authorize_req_id is null ;
   ELSE
        DELETE FROM USER_ROLE_ENTRIES
        WHERE user_id = p_contact_user_id
          AND authorize_req_id =  p_authorize_req_id ;  -- Added by Joshi for 9902.
   END IF;

   pc_log.log_error('pc_users.create_role_entries: p_role_entries.COUNT: ', p_role_entries.COUNT );

   FORALL i IN 1..p_role_entries.COUNT
    INSERT INTO USER_ROLE_ENTRIES
    (ROLE_ENTRY_ID,SITE_NAV_ID,USER_ID,ROLE_ID,START_DATE,STATUS,CREATION_DATE,
     CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY, authorize_req_id)
    VALUES
    (USER_ROLE_ENTRIES_SEQ.NEXTVAL
    ,p_role_entries(i)
    ,p_contact_user_id
    ,p_role_id
    ,SYSDATE
    ,'A'
    ,SYSDATE
    ,p_user_id
    ,SYSDATE
    ,p_user_id
    ,p_authorize_req_id);

  pc_log.log_error('pc_users.create_role_entries: SQLERRM: ', SQLERRM );
 END create_role_entries;


  FUNCTION get_user_permissions ( p_user_id IN NUMBER,p_role_type IN NUMBER)
  RETURN user_roles_t PIPELINED DETERMINISTIC
  IS
     l_record_t user_roles_row_t;
  BEGIN

    IF p_role_type IN (2)  THEN   -- Added by jaggi - role 5'id removed for #9829
        FOR X IN (SELECT site_nav_id, nav_description,account_type
                    FROM site_navigation
                   WHERE STATUS = 'A'
                     AND NVL(END_DATE,SYSDATE) >= SYSDATE
                     AND PORTAL_TYPE = 'EMPLOYER' -- added by jaggi#9912>10172
                ORDER BY site_nav_id)
        LOOP
            l_record_t.site_nav_id := x.site_nav_id;
            l_record_t.user_id := p_user_id;
            l_record_t.account_type := x.account_type;

            l_record_t.nav_description := x.nav_description;
                 PIPE ROW(l_record_t);

          END LOOP;
    ELSE
       FOR X IN ( SELECT sn.site_nav_id, sn.nav_description,sn.account_type
                    FROM online_users x
                        ,user_role_entries ur
                        ,site_navigation sn
                  WHERE x.user_id = ur.user_id
                    AND sn.site_nav_id = ur.site_nav_id
                    AND x.user_id = p_user_id AND conditional_flag = 'N'  --- 8837 rprabu 14/05/2020
                    AND PORTAL_TYPE = 'EMPLOYER'  -- added by jaggi#9912>10172
               ORDER BY sn.site_nav_id)
       LOOP
            l_record_t.site_nav_id := x.site_nav_id;
            l_record_t.user_id := p_user_id;
            l_record_t.account_type := x.account_type;

            l_record_t.nav_description := x.nav_description;
                 PIPE ROW(l_record_t);

       END LOOP;
    END IF;
  END get_user_permissions;
  FUNCTION get_permissions ( p_user_id IN NUMBER,p_role_type IN NUMBER)
  RETURN user_roles_t PIPELINED DETERMINISTIC
  IS
     l_record_t user_roles_row_t;
  BEGIN

    IF p_role_type NOT IN (1, 2) THEN

       FOR X IN ( SELECT sn.site_nav_id, sn.nav_description, sn.account_type
                  FROM  site_navigation sn
                  WHERE  sn.account_type IN ( SELECT a.account_type
                                              FROM account a, enterprise b, online_users x
                                              WHERE a.entrp_id = b.entrp_id
                                                    AND   x.user_id = p_user_id AND conditional_flag = 'N' --- 8837 rprabu 14/05/2020
                                              AND   replace(b.entrp_code,'-') = x.tax_id)
                     ORDER BY sn.site_nav_id )
       LOOP
            l_record_t.site_nav_id := x.site_nav_id;
            l_record_t.nav_description := x.nav_description;
            l_record_t.user_id := p_user_id;
            l_record_t.account_type := x.account_type;

            PIPE ROW(l_record_t);

       END LOOP;
    END IF;
  END get_permissions;
  FUNCTION get_forgotten_user
        ( p_user_name IN VARCHAR2
    , p_find_key  IN VARCHAR2
    , p_email     IN VARCHAR2)
RETURN user_info_t PIPELINED DETERMINISTIC
IS
   e_user_exception         EXCEPTION;
   l_count                  NUMBER := 0;
   l_error_message          VARCHAR2(3200);
   l_login                  VARCHAR2(1) := 'N';
   l_skip_security          VARCHAR2(10) := 'N';
   l_no_of_registration     NUMBER := 0;
   l_record_t               user_info_row_t;
   l_user_id                NUMBER;
   l_no_accounts            NUMBER := 0;
BEGIN
 IF   p_user_name IS NOT NULL
 AND  p_find_key  IS NULL
 AND  p_email     IS NULL THEN

   FOR X IN (SELECT * FROM online_users
             WHERE user_name = p_user_name)
   LOOP
       l_record_t.user_name           := p_user_name;
       l_record_t.user_type           := x.user_type;
       l_record_t.pw_reminder_qut     := x.pw_question;
       l_record_t.pw_reminder_ans     := x.pw_answer;
       l_record_t.acc_num     := x.find_key;
       l_record_t.email     := x.email;
       PIPE ROW (l_record_t);

   END LOOP;

 ELSE
   FOR X IN (SELECT * FROM online_users
             WHERE user_name = p_user_name
         AND   find_key  = p_find_key
         AND   email     = p_email)
   LOOP
       l_record_t.user_name           := p_user_name;
       l_record_t.user_type           := x.user_type;
       l_record_t.pw_reminder_qut     := x.pw_question;
       l_record_t.pw_reminder_ans     := x.pw_answer;
       l_record_t.acc_num     := x.find_key;
       l_record_t.email     := x.email;
       PIPE ROW (l_record_t);
   END LOOP;
 END IF;
END get_forgotten_user;

PROCEDURE reset_password ( p_user_name IN VARCHAR2
                           , p_password  IN VARCHAR2
                           , p_user_id   IN NUMBER)
IS
BEGIN
      pc_log.log_error('reset_password,p_user_name',p_user_name);
      pc_log.log_error('reset_password,p_password',p_password);
      pc_log.log_error('reset_password,p_user_id',p_user_id);


      UPDATE online_users
      SET    password = p_password
          ,  change_pw = to_char(sysdate,'yyyy-mm-dd hh:mi:ss')
          ,  last_update_date  = SYSDATE
          ,  last_updated_by  = p_user_id
          ,  failed_att = 0
          ,  failed_ip = null
          ,  confirmed_flag = 'Y'
          ,  first_time_pw_flag  = 'N'
      WHERE  user_name = p_user_name;
END reset_password;
PROCEDURE set_password ( p_user_name IN VARCHAR2
                       , p_password  IN VARCHAR2
                       , p_pw_question IN VARCHAR2
                           , p_pw_answer   IN VARCHAR2)
IS
BEGIN

      UPDATE online_users
      SET    password = p_password
          ,  change_pw = to_char(sysdate,'yyyy-mm-dd hh:mi:ss')
          ,  last_update_date  = SYSDATE
          ,  last_updated_by  = user_id
          ,  pw_question = p_pw_question
          ,  pw_answer = p_pw_answer
          ,  confirmed_flag = 'Y'
          ,  first_time_pw_flag  = 'N'
        WHERE  user_name = p_user_name;
END set_password;
PROCEDURE confirm_registration ( p_user_name     IN  VARCHAR2,
                                 x_return_status OUT VARCHAR2,
                                          x_error_message OUT VARCHAR2 )
IS
  l_user_id NUMBER;
BEGIN

      x_return_status := 'S';

      SELECT get_user_id(p_user_name)
      INTO   l_user_id
      FROM DUAL;
      IF l_user_id IS NULL THEN
         x_return_status := 'E';
         x_error_message := 'Error in Confirming your registration, Please contact customer service during business hours
                         or email us at customer.service@sterlingadministration.com';
      ELSE

          UPDATE online_users
          SET    confirmed_flag = 'Y'
              ,  last_update_date  = SYSDATE
              ,  last_updated_by  = user_id
              ,  first_time_pw_flag = 'N'
          WHERE  user_name = p_user_name;
          IF SQL%ROWCOUNT > 0 THEN
              x_return_status := 'S';

          END IF;
      END IF;



END confirm_registration;

FUNCTION enroll_acc_exists (p_tax_id IN VARCHAR2)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;
BEGIN
   SELECT COUNT(*) INTO l_count
   FROM online_users WHERE user_type = 'E' and emp_reg_type = '1'
   AND TAX_ID = p_tax_id AND user_status = 'A';

   IF l_count > 0 THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

END enroll_acc_exists;
FUNCTION enroll_new_acct (p_user_id IN VARCHAR2)
RETURN VARCHAR2
IS
  l_new_user VARCHAR2(10) := 'N';
  l_count NUMBER := 0;
BEGIN
  SELECT COUNT(*)
  INTO l_count
  FROM ONLINE_USERS A,ENTERPRISE B ,ACCOUNT C
  where  a.user_id = p_user_id
  and a.tax_id = b.entrp_code
  and b.entrp_id = c.entrp_id
  and c.account_status = 3
 -- and c.complete_flag <> 1
  and a.user_status = 'A' ;


  IF l_count > 0 THEN
     return 'Y';
  END IF;
  l_count := 0;

  SELECT count(*)
  INTO l_count
  FROM LOOKUPS
  WHERE LOOKUP_NAME = 'ACCOUNT_TYPE'
  AND LOOKUP_CODE NOT IN ('CMP','HRA','FSA')
  and LOOKUP_CODE NOT IN (SELECT b.account_type
                         FROM   ENTERPRISE E, ACCOUNT B ,ONLINE_USERS OU
                         WHERE  ou.user_id = p_user_id
                         AND    E.ENTRP_ID = B.ENTRP_ID
                         and    e.entrp_code = OU.TAX_ID);

  IF l_count > 0 THEN
     return 'Y';
  ELSE
     return 'N';
  END IF;

 EXCEPTION
    WHEN TOO_MANY_ROWS THEN
     l_new_user := 'Y';
     return l_new_user;

   WHEN OTHERS THEN
      return 'N';

END enroll_new_acct;

FUNCTION Get_Products ( p_user_id IN NUMBER)
RETURN accounts_t PIPELINED DETERMINISTIC
IS
  l_record accounts_row_t;
BEGIN
  pc_log.log_error('get_products:user_id ',p_user_id);
  FOR X IN ( SELECT emp_reg_type ,tax_id ,user_type
             FROM   online_users
             WHERE  user_id = p_user_id)
  LOOP
     IF x.emp_reg_type IN ('2') THEN   -- Added by jaggi - reg_type 5'id removed for #9829
        FOR xx IN (SELECT acc_num, account_type,account_status,acc_id,entrp_id,broker_id,decline_date
                     FROM emp_OVERVIEW_V where ein=x.tax_id
                      /* Employer Online portal */
                      AND complete_flag = 1
                      AND((X.user_type = 'B' AND account_status IN (1,3))
                       OR (X.user_type = 'G' AND account_status IN (1,3))
                       OR (X.user_type = 'E' AND account_status IN (1,11)) -- 11 Added by Swamy for Ticket#12309
                       OR (X.user_type = 'S' AND account_status IN (1)))  -- added by jaggi #11229
                      AND account_type IN ('HRA','FSA','HSA','COBRA','POP','ERISA_WRAP','FORM_5500','LSA','ACA','CMP','RB'))  -- ACA Added by Swamy for Ticket#10844  -- LSA added by Swamy for Ticket#9912
        LOOP                                                                                                             -- AB Added by Jaggi #11689
          l_record.acc_num := xx.acc_num;                                                                               
          l_record.account_type := xx.account_type;
          l_record.account_status := xx.account_status;
          l_record.meaning := PC_LOOKUPS.GET_ACCOUNT_TYPE(xx.account_type);
          l_record.acc_id := xx.acc_id;
          l_record.entrp_id := xx.entrp_id;
          l_record.broker_id := xx.broker_id;
          l_record.decline_date := xx.decline_date;        -- Added by Swamy for Ticket#8949;

          PIPE ROW (l_record);
        END LOOP;
     ELSE
        FOR xx IN (SELECT acc_num, account_type,account_status,acc_id,entrp_id,broker_id,decline_date
                     FROM emp_OVERVIEW_V A
                    WHERE A.ein=x.tax_id
                      AND complete_flag = 1
                      AND((X.user_type = 'B' AND account_status IN (1,3))
                       OR (X.user_type = 'G' AND account_status IN (1,3))
                       OR (X.user_type = 'E' AND account_status IN (1,11))   -- 11 Added by Swamy for Ticket#12309
                       OR (X.user_type = 'S' AND account_status IN (1)))  -- added by jaggi #11229
                      AND A.account_type IN (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                              WHERE B.USER_ID = p_user_id
                                                AND B.SITE_NAV_ID = C.SITE_NAV_ID))
        LOOP
          l_record.acc_num := xx.acc_num;
          l_record.account_type := xx.account_type;
          l_record.account_status := xx.account_status;
          l_record.meaning := PC_LOOKUPS.GET_ACCOUNT_TYPE(xx.account_type);
          l_record.acc_id := xx.acc_id;
          l_record.entrp_id := xx.entrp_id;
          l_record.broker_id := xx.broker_id;
          l_record.decline_date := xx.decline_date;        -- Added by Swamy for Ticket#8949;

          PIPE ROW (l_record);

        END LOOP;
     END IF;

  END LOOP;

END Get_Products;

-- Whether the ER has completed or not, all the ones he is associated with is listed here
FUNCTION get_all_products ( p_user_id IN NUMBER)
RETURN accounts_t PIPELINED DETERMINISTIC
IS
  l_record accounts_row_t;
BEGIN
  pc_log.log_error('get_products:user_id ',p_user_id);
  FOR X IN ( SELECT emp_reg_type ,tax_id
             FROM   online_users
             WHERE  user_id = p_user_id)
  LOOP
     IF x.emp_reg_type IN ('5', '2') THEN
        FOR xx IN (SELECT  acc_num, account_type,account_status,acc_id,entrp_id,broker_id
                  from emp_OVERVIEW_V where ein=x.tax_id
                    and account_type IN ('HRA','FSA','HSA','COBRA','POP','ERISA_WRAP','FORM_5500')
					AND decline_date IS NULL)  -- Added by Swamy for Ticket#8949
        LOOP
          l_record.acc_num := xx.acc_num;
          l_record.account_type := xx.account_type;
          l_record.account_status := xx.account_status;
          l_record.meaning := PC_LOOKUPS.GET_ACCOUNT_TYPE(xx.account_type);
          l_record.acc_id := xx.acc_id;
          l_record.entrp_id := xx.entrp_id;
          l_record.broker_id := xx.broker_id;

          PIPE ROW (l_record);
        END LOOP;
     ELSE
        FOR xx IN (SELECT  acc_num, account_type,account_status,acc_id,entrp_id,broker_id
                  from emp_OVERVIEW_V A
                  where A.ein=x.tax_id
                   and   A.account_type IN (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = p_user_id
                                             AND B.SITE_NAV_ID = C.SITE_NAV_ID)
										     AND A.decline_date IS NULL)   -- Added by Swamy for Ticket#8949
        LOOP
          l_record.acc_num := xx.acc_num;
          l_record.account_type := xx.account_type;
          l_record.account_status := xx.account_status;
          l_record.meaning := PC_LOOKUPS.GET_ACCOUNT_TYPE(xx.account_type);
          l_record.acc_id := xx.acc_id;
          l_record.entrp_id := xx.entrp_id;
          l_record.broker_id := xx.broker_id;

          PIPE ROW (l_record);

        END LOOP;
     END IF;

  END LOOP;

END get_all_products;


FUNCTION get_nav_list ( p_user_id IN NUMBER,p_account_type IN VARCHAR2
     ,p_is_broker 			 IN VARCHAR2 DEFAULT NULL
     ,p_broker_enroll		 IN VARCHAR2 DEFAULT NULL
     ,p_broker_renewal 		 IN VARCHAR2 DEFAULT NULL
     ,p_broker_invoices 	 IN VARCHAR2 DEFAULT NULL
	 ,p_broker_Enroll_ee     IN VARCHAR2 DEFAULT NULL  --- ticket 7781 prabu on 17/05/2019
     ,p_broker_Enroll_rpts   IN VARCHAR2 DEFAULT NULL  --- ticket 7781 prabu on 17/05/2019
     ,p_broker_ee		     IN VARCHAR2 DEFAULT NULL    --- ticket 7781 prabu on 17/05/2019
	 ,p_Allow_bro_upd_pln_Doc IN VARCHAR2 DEFAULT NULL    --- ticket 8728  prabu on 18/02/2020
     ,p_tax_id IN VARCHAR2 DEFAULT NULL)  RETURN roles_t PIPELINED DETERMINISTIC is
 l_record roles_row_t;
 l_tax_id varchar2(100);
 l_renew VARCHAR2(10);
BEGIN
 IF p_is_broker = 'Y' THEN /*Ticket#6834 Broker Details */
            FOR XX IN( SELECT WEB_NAV_CODE,WEB_NAV_URL,NAV_DESCRIPTION
                  FROM   SITE_NAVIGATION C
                   WHERE   C.STATUS = 'A'
                   and     c.account_type  = p_account_type
                   and  (  c.nav_code like '%ACCSUM'
				          OR    (c.nav_code like '%_EE'          and p_broker_ee ='Y'	      )  --- 7781
                      	  OR    (c.nav_code like '%_ENROLL'      and p_broker_Enroll_ee ='Y'  )   --- 7781
                          OR    (c.nav_code like '%_REP'		 and p_broker_Enroll_rpts ='Y') )  --- 7781
                   ORDER BY c.seq_no ASC)
            LOOP
                      l_record.nav_code        := XX.WEB_NAV_CODE;
                      l_record.redirect_url    := XX.WEB_NAV_URL;
                      l_record.url_description  := XX.NAV_DESCRIPTION;

                      PIPE ROW (l_record);
            END LOOP;

           IF p_broker_enroll = 'Y' THEN
                l_record.nav_code        := 'products';
                l_record.redirect_url    := '/Accounts/Portfolio/newEREnroll/';
                l_record.url_description  := 'Products';
              PIPE ROW (l_record);
          END IF;

            IF p_broker_renewal = 'Y' THEN
                 FOR xx IN (SELECT  acc_num, account_type,account_status,acc_id,entrp_id,broker_id
                      from emp_OVERVIEW_V where ein=p_tax_id
                      and account_type = p_account_type
                      )
                   LOOP

						IF p_account_type = 'FORM_5500'  THEN   -- Ticket#8049 done by rprabu
                             FOR X IN ( SELECT RENEWED
                                         FROM  TABLE (PC_WEB_COMPLIANCE.GET_ER_PLANS(xx.acc_id,'FORM_5500',p_tax_id))
                                         )/*Modified for Ticket#7306 */
                             LOOP
                                l_renew := X.RENEWED;
                                IF l_renew = 'N' THEN
                                  l_record.nav_code        := 'form5500_renewal';
                                  l_record.redirect_url    :=  '/Employers/OnlineRenewal/';    -- Ticket#5759 done by rprabu
                                  l_record.url_description  := 'Renewal';
                                  PIPE ROW (l_record);
                               END IF;
                            END LOOP;
                        END IF;
					   IF p_account_type = 'ERISA_WRAP'  THEN
                             FOR X IN ( SELECT RENEWED
                                         FROM  TABLE (PC_WEB_COMPLIANCE.GET_ER_PLANS(xx.acc_id,'ERISA_WRAP',p_tax_id))
                                         )/*Modified for Ticket#7306 */
                             LOOP
                                l_renew := X.RENEWED;
                                IF l_renew = 'N' THEN
                        --AND PC_WEB_COMPLIANCE.EMP_PLAN_RENEWAL_DISP_ERISA(xx.acc_id) = 'Y'
                                  l_record.nav_code        := 'erisa_renewal';
                                 --- l_record.redirect_url    := '/ERISA/Employers/Renewal/';--  commented for Ticket#5759 done by rprabu
                                  l_record.redirect_url    :=     '/Employers/OnlineRenewal/';    -- Ticket#5759 done by rprabu
                                  l_record.url_description  := 'Renewal';
                                  PIPE ROW (l_record);
                               END IF;
                            END LOOP;
                        END IF;

                         IF p_account_type = 'COBRA'
                         AND PC_WEB_COMPLIANCE.EMP_PLAN_RENEWAL_DISP_COBRA(xx.acc_id) = 'Y'
                         THEN
                            l_record.nav_code        := 'cobra_renewal';
                     --       l_record.redirect_url    := '/COBRA/Employers/Renewal/';--  commented for Ticket#5759 done by rprabu
                            l_record.redirect_url    := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                            l_record.url_description  := 'Renewal';
                            PIPE ROW (l_record);

                         END IF;

                        IF p_account_type IN ( 'FSA','HRA')
                         AND PC_WEB_ER_RENEWAL.EMP_PLAN_RENEWAL_DISP(xx.acc_id) = 'Y'
                         THEN
                            l_record.nav_code        := 'online_Renewal';
                            l_record.redirect_url    := '/Employers/OnlineRenewal/';
                            l_record.url_description  := 'Plan Renewal';
                            PIPE ROW (l_record);

                         END IF;
             END LOOP;
          END IF; /*Broker renewal IF */
                    pc_log.log_error('Here...123',p_broker_invoices);

            IF p_broker_invoices = 'Y' THEN
                FOR  XX IN ( SELECT WEB_NAV_CODE,WEB_NAV_URL,NAV_DESCRIPTION,nav_code
                            FROM   SITE_NAVIGATION C
                             WHERE    C.STATUS = 'A'
                             and    c.account_type  = p_account_type
                             and  upper(nav_code) like '%INV%'
                             ORDER BY c.seq_no ASC
                             )
                LOOP
                       l_record.nav_code        := XX.WEB_NAV_CODE;
                       l_record.redirect_url    := XX.WEB_NAV_URL;
                       l_record.url_description  := XX.NAV_DESCRIPTION;
                  PIPE ROW (l_record);
                END LOOP;
    END IF; /*Broker Invoice IF */

    -------- 8728  rprabu 18/02/2020

      IF p_Allow_bro_upd_pln_Doc  = 'Y' THEN
                FOR  XX IN ( SELECT Web_Nav_Code,Web_Nav_Url,Nav_Description,Nav_Code
                            FROM   SITE_NAVIGATION C
                             WHERE    C.Status = 'A'
                               and    c.account_type  = p_account_type
                             and  upper(Web_Nav_Code)  =   'PLAN_DOC'
                             ORDER BY c.seq_no ASC
                             )
                LOOP
                       l_record.nav_code         := XX.Web_Nav_Code;
                       l_record.redirect_url     := XX.Web_Nav_Url;
                       l_record.url_description  := XX.Nav_Description;
                  PIPE ROW (l_record);
                END LOOP;
    END IF; /*Broker  plan document Yes */

    -------- 8728 END   rprabu 18/02/2020


  ELSE /*Employer  */
   FOR X IN ( SELECT emp_reg_type ,tax_id
             FROM   online_users
             WHERE  user_id = p_user_id)
   LOOP
      l_tax_id := x.tax_id;
     IF x.emp_reg_type  IN ('5', '2')  THEN
       FOR XX IN ( SELECT WEB_NAV_URL,NAV_DESCRIPTION,WEB_NAV_CODE
        FROM   SITE_NAVIGATION
        WHERE  ACCOUNT_TYPE = p_account_type
            AND     STATUS = 'A'
        ORDER BY seq_no ASC)
      LOOP
        l_record.nav_code        := XX.WEB_NAV_CODE;
        l_record.redirect_url    := XX.WEB_NAV_URL;
        l_record.url_description  := XX.NAV_DESCRIPTION;
        PIPE ROW (l_record);
      END LOOP;


     ELSE
        FOR XX IN ( SELECT WEB_NAV_URL,NAV_DESCRIPTION,WEB_NAV_CODE
            FROM    USER_ROLE_ENTRIES B, SITE_NAVIGATION C
            WHERE   B.SITE_NAV_ID = C.SITE_NAV_ID
            AND     B.USER_ID = p_user_id
            AND     C.STATUS = 'A'
             and    c.account_type  = p_account_type
             ORDER BY c.seq_no ASC)
          LOOP
            l_record.nav_code        := XX.WEB_NAV_CODE;
            l_record.redirect_url    := XX.WEB_NAV_URL;
            l_record.url_description  := XX.NAV_DESCRIPTION;
        PIPE ROW (l_record);

          END LOOP;
     END IF;


         l_record.nav_code        := 'user_profile';
         l_record.redirect_url    := '/Accounts/Profiles/ERUserProfile/';
         l_record.url_description  := 'User Profile';
         PIPE ROW (l_record);
         IF PC_USERS.enroll_new_acct(p_user_id) = 'Y' THEN
            l_record.nav_code        := 'products';
            l_record.redirect_url    := '/Accounts/Portfolio/newEREnroll/';
            l_record.url_description  := 'Products';
            PIPE ROW (l_record);

         END IF;

         IF x.emp_reg_type  IN ('5', '2')  THEN
               l_record.nav_code        := 'company_profile';
             l_record.redirect_url    := '/Accounts/Profiles/CompanyProfile/';
             l_record.url_description  := 'Company Profile';
                        PIPE ROW (l_record);

            l_record.nav_code        := 'manage_user';
           l_record.redirect_url    := '/Accounts/User/ManageAdmin/';
           l_record.url_description  := 'Manage Site Users';
           PIPE ROW (l_record);

         END IF;
          l_record.nav_code        := 'messages';
         l_record.redirect_url    := '/Accounts/Messages/MessageCenter/';
         l_record.url_description  := 'Message Center';
         PIPE ROW (l_record);
           FOR xx IN (SELECT  acc_num, account_type,account_status,acc_id,entrp_id,broker_id
                      from emp_OVERVIEW_V
					  Where ein=l_tax_id
					  And account_type = p_account_type ---    fixed by prabu 17/05/2019  Ticket #7314
                      )
         LOOP
                     IF p_account_type = 'FORM_5500'  THEN   -- Ticket#8049 done by rprabu
                             FOR X IN ( SELECT RENEWED
                                         FROM  TABLE (PC_WEB_COMPLIANCE.GET_ER_PLANS(xx.acc_id,'FORM_5500',p_tax_id))
                                         )/*Modified for Ticket#7306 */
                             LOOP
                                l_renew := X.RENEWED;
                                IF l_renew = 'N' THEN
                                  l_record.nav_code        := 'form5500_renewal';
                                  l_record.redirect_url    :=  '/Employers/OnlineRenewal/';    -- Ticket#5759 done by rprabu
                                  l_record.url_description  := 'Renewal';
                                  PIPE ROW (l_record);
                               END IF;
                            END LOOP;
                        END IF;
			   IF xx.account_type = 'ERISA_WRAP'  THEN
                 SELECT RENEWED INTO L_renew FROM  TABLE (PC_WEB_COMPLIANCE.GET_ER_PLANS(xx.acc_id,'ERISA_WRAP',l_tax_id));/*Modified for Ticket#7306 */
                 IF l_renew = 'N' THEN
              --AND PC_WEB_COMPLIANCE.EMP_PLAN_RENEWAL_DISP_ERISA(xx.acc_id) = 'Y'
                      l_record.nav_code        := 'erisa_renewal';
                     --- l_record.redirect_url    := '/ERISA/Employers/Renewal/'; -- commented for  Ticket#5759 done by rprabu
                      l_record.redirect_url    := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                      l_record.url_description  := 'Renewal';
                      PIPE ROW (l_record);
                  END IF;

               END IF;
               IF xx.account_type = 'COBRA'
               AND PC_WEB_COMPLIANCE.EMP_PLAN_RENEWAL_DISP_COBRA(xx.acc_id) = 'Y'
               THEN
                  l_record.nav_code        := 'cobra_renewal';
               ---   l_record.redirect_url    := '/COBRA/Employers/Renewal/'; -- commented for  Ticket#5759 done by rprabu
                  l_record.redirect_url    := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                  l_record.url_description  := 'Renewal';
                  PIPE ROW (l_record);

               END IF;

                     --- 7794 rprabu 07/04/2020
                      IF xx.account_type = 'POP'
               AND PC_WEB_COMPLIANCE.EMP_PLAN_RENEWAL_DISP_POP(xx.acc_id, 'POP' ) = 'Y'
               THEN
                  l_record.nav_code        := 'pop_renewal';
                  l_record.redirect_url    := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                  l_record.url_description  := 'Renewal';
                  PIPE ROW (l_record);
           END IF;
                    --- 7794 rprabu 07/04/2020

              IF xx.account_type IN ( 'FSA','HRA')
               AND PC_WEB_ER_RENEWAL.EMP_PLAN_RENEWAL_DISP(xx.acc_id) = 'Y'
               THEN
                  l_record.nav_code        := 'online_Renewal';
                  l_record.redirect_url    := '/Employers/OnlineRenewal/';
                  l_record.url_description  := 'Plan Renewal';
                  PIPE ROW (l_record);

               END IF;


         END LOOP;
   END LOOP;
END IF; /*Broker Employer IF */
END get_nav_list;


 --- rprabu 06/05/2020 #ticket 8837
 FUNCTION get_nav_list_v2_old
    ( p_user_id                IN NUMBER
     ,p_account_type           IN VARCHAR2
     ,p_is_broker 		       IN VARCHAR2 DEFAULT NULL
     ,p_broker_enroll	       IN VARCHAR2 DEFAULT NULL
     ,p_broker_renewal 		   IN VARCHAR2 DEFAULT NULL
     ,p_broker_invoices   	   IN VARCHAR2 DEFAULT NULL
	 ,p_broker_Enroll_ee       IN VARCHAR2 DEFAULT NULL
     ,p_broker_Enroll_rpts     IN VARCHAR2 DEFAULT NULL
     ,p_broker_ee		       IN VARCHAR2 DEFAULT NULL
	 ,p_Allow_bro_upd_pln_Doc IN VARCHAR2 DEFAULT NULL
     ,p_tax_id                IN VARCHAR2 DEFAULT NULL)  RETURN pc_users.roles_t PIPELINED DETERMINISTIC is

 l_record  pc_users.roles_row_t;

 l_tax_id varchar2(100);
 l_renew VARCHAR2(10);
BEGIN

     FOR X IN (SELECT tax_id, emp_reg_type, user_type
                FROM  online_users
               WHERE  user_id  = p_user_id  )
     LOOP
        IF x.user_type = 'E' THEN

			IF NVL(p_is_broker,'N') = 'N' THEN /*Ticket#6834 Broker Details */

			    FOR  ER_NAV  in  (
					SELECT  WEB_NAV_URL,   NAV_DESCRIPTION,     WEB_NAV_CODE,seq_no
					FROM (
					        SELECT  Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
					          FROM  SITE_NAVIGATION
					         WHERE  ACCOUNT_TYPE = p_account_type
					           AND  STATUS = 'A'
                     AND  Portal_type = 'EMPLOYER'
					           AND  conditional_flag = 'N' AND x.emp_reg_type IN ('2') -- Added by jaggi - role 5'id removed for #9829
					        UNION
					        SELECT  Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
					          FROM  SITE_NAVIGATION s, USER_ROLE_ENTRIES ur
					         WHERE  s.ACCOUNT_TYPE = p_account_type
					           AND  s.STATUS = 'A'
					           AND  s.site_nav_id = ur.site_nav_id
					           AND  ur.user_id = p_user_id
                     AND  Portal_type = 'EMPLOYER'
					           AND  s.conditional_flag = 'N' AND x.emp_reg_type NOT IN ('2') -- Added by jaggi - role 5'id removed for #9829
					        UNION
					        SELECT  Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
					          FROM  SITE_NAVIGATION s
                             WHERE  nav_code  in ('user_profile',  'messages')   -- Removed products nav_code by swamy for Ticket#9891 on 18/05/2021 and added it below
                               AND  Portal_type = 'EMPLOYER'
					           AND  PC_USERS.enroll_new_acct(p_user_id) = 'Y'
					        UNION                                                -- Added Union cond by swamy for Ticket#9891 on 18/05/2021
                            SELECT  Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
					          FROM  SITE_NAVIGATION s
                             WHERE  nav_code  =  'products'
                               AND  Portal_type = 'EMPLOYER'
					           AND  PC_USERS.enroll_new_acct(p_user_id) = 'Y'
                               AND  x.emp_reg_type <> '5'
					        UNION
					        SELECT  Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
					          FROM (      SELECT account_type
					                         ,CASE WHEN account_type IN ('HRA','FSA') THEN
					                                   Pc_Web_Er_Renewal.Emp_Plan_Renewal_Disp(Xx.Acc_Id)
					                           WHEN  account_type = 'COBRA' THEN
					                             Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Cobra(Xx.Acc_Id)
					                           WHEN account_type = 'POP' THEN
					                             Nvl(Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Pop(xx.acc_id,'POP'), 'N') -- 8837
					                           WHEN account_type = 'FORM_5500' THEN
                                                 Pc_Web_Compliance.Emp_Plan_Renwl_Disp_Form_5500(xx.acc_id)
					                           WHEN account_type = 'ERISA_WRAP' THEN
					                             Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Erisa(xx.acc_id)
                                              END renewed
					                    FROM  emp_overview_v xx
					                    WHERE EIN = p_tax_id
					                    AND   account_type = p_account_type
					                    AND   account_type IN ('HRA','FSA','COBRA','ERISA_WRAP','FORM_5500','POP')
					                ) renewal,      Site_Navigation s
					        WHERE   renewal.account_type = s.account_type
					          AND   renewal.renewed = 'Y'
					          AND   s.PORTAL_TYPE = 'EMPLOYER'
					          AND   s.nav_code = 'renewal'
					          AND   s.conditional_flag = 'Y'
                              AND  x.emp_reg_type <> '5'      -- Added AND cond by swamy for Ticket#9891 on 18/05/2021
					        UNION
					        SELECT  Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
					          FROM  Site_Navigation s
					          WHERE nav_code not in ('renewal','products')
                      AND Portal_type = 'EMPLOYER'
					            AND conditional_flag = 'Y' AND x.emp_reg_type IN ('2') -- Added by jaggi - role 5'id removed for #9829
                  UNION
                  -- Added by Joshi for 9072 (EDI Feed menu option should be shown only when EDI flag is 'Y'
					         SELECT  Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
					           FROM  Site_Navigation s
					          WHERE  nav_code = 'edi_feeds'
                      AND  Portal_type = 'EMPLOYER'
					            AND  x.emp_reg_type IN ('2') -- Added by jaggi - role 5'id removed for #9829
                      AND  pc_account.get_edi_flag(p_tax_id) = 'Y'
					        )
					ORDER BY seq_no ASC)
			LOOP
			        		L_Record.Nav_Code        := Er_Nav.Web_Nav_Code;
                    		L_Record.Redirect_Url    := Er_Nav.Web_Nav_Url;
	                    	L_Record.Url_Description  := Er_Nav.Nav_Description;
               PIPE ROW (l_record);

			END LOOP;
            null;
        ELSE
    		    FOR    NAV_Details  in  (
					SELECT  WEB_NAV_URL,          NAV_DESCRIPTION,     WEB_NAV_CODE
					FROM (
					        SELECT Site_Nav_Id,   Web_Nav_Url,   Nav_Description,     Web_Nav_Code,       Seq_No,  Nav_Code
					        FROM   Site_Navigation
					        WHERE  ACCOUNT_TYPE = p_account_type
					          AND  STATUS = 'A'
                              And  Portal_type = 'EMPLOYER'
					          AND  conditional_flag = 'N'
                        UNION
					        SELECT    Site_Nav_Id,   Web_Nav_Url,   Nav_Description,     Web_Nav_Code,       Seq_No,  Nav_Code
					        FROM    Site_Navigation
					        WHERE  nav_code = 'products'
					        AND    Pc_Users.enroll_new_acct(p_user_id) = 'Y'
					        AND    p_broker_enroll = 'Y'
                            And  Portal_type = 'EMPLOYER'
					        UNION
					        SELECT  Site_Nav_Id,   Web_Nav_Url,   Nav_Description,     Web_Nav_Code,       Seq_No,  Nav_Code
					        FROM (      SELECT account_type
					                           ,CASE WHEN account_type IN ('HRA','FSA') THEN
                                                Pc_Web_Er_Renewal.Emp_Plan_Renewal_Disp(xx.acc_id)
					                            WHEN  account_type = 'COBRA' THEN
					                             Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Cobra(xx.acc_id)
					                            WHEN account_type = 'POP' THEN
					                             Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Pop(xx.acc_id,'POP')
					                             WHEN account_type = 'FORM_5500' THEN
                                                   Pc_Web_Compliance. Emp_Plan_Renwl_Disp_Form_5500(xx.acc_id)
					                            WHEN account_type = 'ERISA_WRAP' THEN
					                             Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Erisa(xx.acc_id)
                                              END renewed
					                    FROM  emp_overview_v xx
					                    WHERE Ein = p_tax_id
					                    AND   account_type = p_account_type
					                    AND   account_type IN ('HRA','FSA','COBRA','ERISA_WRAP','FORM_5500','POP')
					                ) renewal, SITE_NAVIGATION s
					        WHERE    renewal.account_type = s.account_type
					        And      renewal.renewed = 'Y'
					        And      s.Portal_Type = 'EMPLOYER'
					        And      s.nav_code = 'renewal'
					        And      s.conditional_flag = 'Y'
					        And      p_broker_renewal = 'Y') c
                         WHERE  c.web_nav_code = 'employer_dashboard'
                           OR  ( c.nav_code   In ('products' , 'renewal'  )  )
                           OR    (c.web_nav_code = 'employees'                 And p_broker_ee ='Y'   )
                       	   OR    (c.web_nav_code = 'bulkenrollment'            And p_broker_Enroll_ee ='Y'  )
                           OR    (Upper(c.web_nav_code)  like '%REPORT%'       And p_broker_Enroll_rpts ='Y')
                           OR    (c.web_nav_code in ('plan_doc','upload_rate_plans' ) And p_Allow_bro_upd_pln_Doc = 'Y')
                           OR    (upper(c.web_nav_code) like '%INV%'           And p_broker_invoices = 'Y')
				   ORDER BY seq_no ASC)
			LOOP
			        L_Record.Nav_Code                   := Nav_Details.Web_Nav_Code;
                    L_Record.Redirect_Url              := Nav_Details.Web_Nav_Url;
                    L_Record.Url_Description        := Nav_Details.Nav_Description;
                    PIPE ROW (l_record);
            END LOOP;
	     END IF;

        ELSIF x.user_type IN ('G','B') THEN -- 8890 rprabu 17/06/2020

        	      L_Record.Nav_Code                    :=  null;
           	     	L_Record.Redirect_Url             := Null;
		            L_Record.Url_Description       := null;
             FOR Broker_Nav  In  (
					SELECT    Web_Nav_Url,Nav_Description,Web_Nav_Code , seq_no
					FROM (
					        SELECT   WEB_NAV_URL,NAV_DESCRIPTION,WEB_NAV_CODE , seq_no
					        FROM   SITE_NAVIGATION
             	        WHERE  STATUS = 'A'
                               and portal_type =  decode(x.user_type, 'B', 'BROKER',  'G' , 'GA' )
					          AND x.emp_reg_type IN ('5','2')
					        UNION
					        SELECT WEB_NAV_URL,NAV_DESCRIPTION,WEB_NAV_CODE  , seq_no
					        FROM   SITE_NAVIGATION s, USER_ROLE_ENTRIES ur
					        WHERE  s.STATUS = 'A'
					          AND  s.site_nav_id = ur.site_nav_id
					          AND  ur.user_id = p_user_id
                               and portal_type =  decode(x.user_type, 'B', 'BROKER',  'G' , 'GA' )
					          AND x.emp_reg_type NOT IN ('5','2')
                    )
                    ORDER BY seq_no ASC)
    		LOOP
			   		L_Record.Nav_Code                := Broker_Nav.Web_Nav_Code;
           	     	L_Record.Redirect_Url            := Broker_Nav.Web_Nav_Url;
		            L_Record.Url_Description      := Broker_Nav.Nav_Description;
                    PIPE ROW (l_record);
         	END LOOP;
     END IF;
   END LOOP;
END get_nav_list_v2_old;
FUNCTION get_user_details( P_TAX_ID IN VARCHAR2, P_CONF_EMAIL_TYPE IN VARCHAR2)
RETURN user_det_t PIPELINED DETERMINISTIC
IS
   l_record_t user_detail_row_t;
BEGIN
  IF P_CONF_EMAIL_TYPE = 'CONFIRMATION_EMAIL' THEN
           FOR X IN ( SELECT USER_NAME, EMAIL , USER_TYPE,  CONFIRMED_FLAG
                        FROM   ONLINE_USERS
                        WHERE  TAX_ID = P_TAX_ID)
           LOOP
              l_record_t.user_name := x.user_name;
              l_record_t.email := x.email;
              l_record_t.user_type := x.user_type;
              l_record_t.confirmed_flag := x.confirmed_flag;
              l_record_t.registered := 'Y';
          END LOOP;
          IF l_record_t.user_type = 'E' THEN
             FOR X IN ( SELECT NAME,b.account_type,b.acc_num FROM ENTERPRISE a, ACCOUNT B
                         WHERE regexp_REPLACE(ENTRP_CODE,'[^[:digit:]]+','') = (regexp_REPLACE(P_TAX_ID,'[^[:digit:]]+',''))
                         and    a.entrp_id = b.entrp_id
                         AND   B.ACCOUNT_TYPE IN ('HRA','FSA','HSA'))
             LOOP
               L_RECORD_T.name := x.name;
               L_RECORD_T.account_type := x.account_type;
               L_RECORD_T.acc_num := x.acc_num;
             END LOOP;
          END IF;
          IF l_record_t.user_type = 'S' THEN
             FOR X IN ( SELECT FIRST_NAME||' '||LAST_NAME name, b.account_type,b.acc_num
                         FROM PERSON a, account b
                         WHERE SSN = FORMAT_SSN(P_TAX_ID)
                         AND   A.PERS_ID = B.PERS_ID
                         AND   B.ACCOUNT_TYPE IN ('HRA','FSA','HSA'))
             LOOP
               L_RECORD_T.name := x.name;
               L_RECORD_T.account_type := x.account_type;
               L_RECORD_T.acc_num := x.acc_num;

             END LOOP;
          END IF;
          IF l_record_t.user_type = 'B' THEN
             FOR X IN ( SELECT FIRST_NAME||' '||LAST_NAME name
                         FROM PERSON A, BROKER B
                         WHERE A.PERS_ID = B.BROKER_ID AND B.BROKER_LIC = P_TAX_ID)
             LOOP
               L_RECORD_T.name := x.name;
             END LOOP;
          END IF;
                    PIPE ROW (l_record_t);

  END IF;
  IF P_CONF_EMAIL_TYPE = 'MASS_ENROLL_EMAIL' THEN
     for x in (SELECT  A.ENTRP_ID, A.FIRST_NAME||' '||A.LAST_NAME name , A.EMAIL, B.ACC_NUM, B.ACCOUNT_TYPE
                FROM    PERSON a, account b
                WHERE   A.SSN = FORMAT_SSN(P_TAX_ID)
                AND     A.PERS_ID = B.PERS_ID)
     LOOP
               L_RECORD_T.name := x.name;
               L_RECORD_T.account_type := x.account_type;
               L_RECORD_T.acc_num := x.acc_num;
               L_RECORD_T.employer_id := pc_entrp.get_acc_num(x.entrp_id);

     END LOOP;
     for x in (
        SELECT ENROLLMENT_ID
        FROM   ONLINE_ENROLLMENT
        WHERE  ACC_NUM = L_RECORD_T.acc_num)
     loop
               L_RECORD_T.enrollment_id := x.enrollment_id;
     end loop;
     for x in (
        SELECT USER_NAME, EMAIL , USER_TYPE, CONFIRMED_flag
        FROM   ONLINE_USERS
        WHERE  TAX_ID = P_TAX_ID
      ) loop
              l_record_t.user_name := x.user_name;
              l_record_t.email := x.email;
              l_record_t.user_type := x.user_type;
              l_record_t.confirmed_flag := x.confirmed_flag;
              l_record_t.registered := 'Y';

      end loop;
      if L_RECORD_T.enrollment_id  Is not null then
          PIPE ROW (l_record_t);
      end if;
  END IF;
END get_user_details;
FUNCTION get_ee_enrolled_products ( p_ssn IN VARCHAR2)
RETURN accounts_t PIPELINED DETERMINISTIC
IS
  l_record accounts_row_t;
BEGIN
  FOR X IN (  SELECT  acc_num, account_type , acc_num||'('||account_type||')' meaning
                    ,  pc_lookups.get_account_type (account_type)  account_type_meaning
                    ,  DECODE(ACCOUNT_TYPE, 'COBRA',NULL, ACC_BALANCE) ACC_BALANCE
                    ,  DECODE(ACCOUNT_TYPE, 'COBRA',1, account_status) account_status
                    ,  pc_lookups.GET_meaning(P_LOOKUP_CODE => account_status,P_LOOKUP_NAME => 'ACCOUNT_STATUS') account_status_meaning  -- Added by Swamy for Ticket#10978 13062024
                    ,  DECODE(ACCOUNT_TYPE, 'COBRA',NULL, PC_WEB_UTILITY_PKG.HAS_ACTIVE_PLAN(ACC_NUM)) PLAN_COUNT
                    ,  DECODE(ACCOUNT_TYPE, 'COBRA',NULL, CLOSED_REASON) CLOSED_REASON
                    ,   acc_id,entrp_id
					,   show_account_online              -- Added by Swamy for Ticket#9332 on 06/11/2020
           from acc_OVERVIEW_V where TAX_ID = p_SSN
               and account_type IN ('HRA','FSA','HSA','RB','LSA','ACA','CMP')  -- ACA added by Swamy for Ticket#10844      -- Added by Swamy for Ticket#9912 on 10/08/2021   -- Added RB by Swamy for Ticket#9656 on 24/03/2021
           UNION
           SELECT  acc_num, 'COBRA' , acc_num||'(COBRA)' meaning
                ,  'COBRA'  account_type_meaning
                ,  null
                ,  1
                ,  pc_lookups.GET_meaning(P_LOOKUP_CODE => 1,P_LOOKUP_NAME => 'ACCOUNT_STATUS') account_status_meaning   -- Added by Swamy for Ticket#10978 13062024
                ,  null
                ,  NULL
                ,b.acc_id, c.entrp_id
				,b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
         FROM   QB A, ACCOUNT B, PERSON C
         WHERE  A.SSN = C.SSN
         AND    C.SSN = FORMAT_SSN(p_SSN)
        AND  A.ALLOWSSO = 1 AND B.MIGRATED_FLAG = 'N'
        AND  A.ACTIVE = 1
        --AND    C.ORIG_SYS_VENDOR_REF = A.MEMBERID
         AND    B.PERS_ID = C.PERS_ID AND B.account_type  = 'COBRA'
           UNION
           SELECT  acc_num, 'COBRA' , acc_num||'(COBRA)' meaning
                ,  'COBRA'  account_type_meaning
                ,  null
                ,  1
                ,  pc_lookups.GET_meaning(P_LOOKUP_CODE => 1,P_LOOKUP_NAME => 'ACCOUNT_STATUS') account_status_meaning   -- Added by Swamy for Ticket#10978 13062024
                ,  null
                ,  NULL
                ,b.acc_id, c.entrp_id
				,b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
         FROM   ACCOUNT B, PERSON C
         WHERE   c.SSN = FORMAT_SSN(p_SSN)
         -- AND B.MIGRATED_FLAG = 'Y'
        AND  b.account_status = 1
        --AND    C.ORIG_SYS_VENDOR_REF = A.MEMBERID
         AND    B.PERS_ID = C.PERS_ID AND B.account_type  = 'COBRA'
         )
  LOOP
   IF NVL(X.CLOSED_REASON,'-1') <> 'CLOSED_NON_FUNDS' THEN
     l_record.acc_num := x.acc_num;
     l_record.account_type := x.account_type;
     l_record.meaning := x.meaning;
     l_record.account_type_meaning := x.account_type_meaning;
     l_record.acc_balance := x.acc_balance;
     l_record.account_status := x.account_status;
     l_record.plan_count := x.plan_count;
     l_record.acc_id := x.acc_id;
     l_record.entrp_id := x.entrp_id;
     l_record.show_account_online := x.show_account_online;  -- Added by Swamy for Ticket#9332 on 06/11/2020     
     l_record.account_status_meaning := x.account_status_meaning; -- Added by Swamy for Ticket#10978 13062024

     PIPE ROW(l_record);
   END IF;
  END LOOP;

END get_ee_enrolled_products;

FUNCTION get_er_enrolled_products ( p_ein IN VARCHAR2)
RETURN accounts_t PIPELINED DETERMINISTIC
IS
  l_record accounts_row_t;
BEGIN
    FOR X IN ( SELECT  acc_id,acc_num, account_type , acc_num||'('||account_type||')' meaning
               from emp_OVERVIEW_V where ein=replace(p_ein,'-')
               and account_type <> 'COBRA'
                and account_status = 1
                    UNION
               SELECT  acc_id,acc_num, account_type , acc_num||'('||account_type||')' meaning
               from emp_OVERVIEW_V where  ein=replace(p_ein,'-')
               and account_type  = 'COBRA'
                and account_status = 1
				)
                    -- Commented by Swamy for Ticket#11605 05/05/2023
					/*AND EXISTS (   SELECT LOWER(A.SSOIDENTIFIER) SSOIDENTIFIER,B.CLIENTID
                              FROM CLIENTCONTACT A, CLIENT B
                              WHERE A.CLIENTID = B.CLIENTID
                              AND   A.ALLOWSSO = 1
                              AND   a.firstname IS NOT NULL
                              AND   A.LASTNAME IS NOT NULL
                              AND   A.ACTIVE = 1
                              AND   TO_CHAR(B.EIN) = REPLACE(replace(emp_OVERVIEW_V.EIN,'-'),' ','')))*/

  LOOP
     l_record.acc_num := x.acc_num;
     l_record.account_type := x.account_type;
     l_record.meaning := x.meaning;
     l_record.acc_id := x.acc_id;

     PIPE ROW(l_record);

  END LOOP;

END get_er_enrolled_products;

  FUNCTION is_portfolio_account(p_ssn IN VARCHAR2) RETURN VARCHAR2
  IS
    l_flag VARCHAR2(1) := 'N';
    L_COUNT number := 0;
  BEGIN

    SELECT COUNT(*)
    INTO L_COUNT
    FROM person a,
         account b
    WHERE A.SSN = FORMAT_SSN(P_SSN)
    AND a.pers_id     = b.pers_id
    AND NVL(B.CLOSED_REASON,'-1') <> 'CLOSED_NO_FUNDS';

    if L_COUNT > 1 then
      return 'Y';
    ELSE
       SELECT COUNT(*)
      INTO L_COUNT
      FROM enterprise a,
         account b
      WHERE A.entrp_code = replace(replace(p_ssn,'-'),' ')
      AND a.entrp_id     = b.entrp_id  ;
       if L_COUNT > 1 then
          return 'Y';
       else
          RETURN 'N';
       end if;
    END IF;
  END is_portfolio_account;


FUNCTION get_er_not_enrolled_plans( p_ein IN VARCHAR2)
RETURN accounts_t PIPELINED DETERMINISTIC
IS
  l_record accounts_row_t;
  p_user_id NUMBER;
  l_max_plan_end_date date;
BEGIN

    FOR X IN (SELECT  acc_num, account_type , acc_num||'('||account_type||')' meaning
                     ,a.acc_id,b.entrp_id
                     ,a.complete_flag
                     ,a.account_status
                     ,C.meaning           Status_meaning    -- Added  By Rprabu For Ticket#9141 On 17/08/2020
                     ,Enrolle_Type                          -- Added  By Rprabu For Ticket#9141 On 30/07/2020
                     ,Enrolled_By                           -- Added  By Rprabu For Ticket#9141 On 30/07/2020
                     ,resubmit_flag                         -- Added  by Jagggi for Ticket#10430 on 04/11/2021
                     ,a.Signature_account_status             -- Added by Swamy for Tiecket#11364(Broker)
               FROM ACCOUNT a , ENTERPRISE B , lookups C
              WHERE b.entrp_code =replace(p_ein,'-')
                AND b.entrp_id = a.entrp_id
             -- and complete_flag <> 1 --Not enrolled plans
                AND decline_date IS NULL --Plans not declined
                AND c.lookup_code = to_char(a.account_status )           -- Added  By Rprabu For Ticket#9141 On 17/08/2020
                AND lookup_name = 'ACCOUNT_STATUS'                       -- Added  By Rprabu For Ticket#9141 On 17/08/2020
			    AND a.account_status <> '4'   -- Added by Swamy for Ticket#8123
   UNION
            --Existing Users
            select NULL,lookup_code account_type, meaning ,NULL,NULL,NULL
                 , null, null,null, null,null,null
            from lookups
            where lookup_name = 'ACCOUNT_TYPE'
            and lookup_code NOT IN ('SBS', 'CMP', 'RB','ACA') -- added 'ACA' and 'RB' for ticket 8238.
            and not exists ( select * from  ACCOUNT a , ENTERPRISE B
                              where b.entrp_code =replace(p_ein,'-')
                               and b.entrp_id = a.entrp_id
                               and a.account_type = lookups.lookup_code)
          )
     LOOP
     l_record.acc_num               := x.acc_num;
     l_record.account_type          := x.account_type;
     l_record.meaning               := x.meaning;
     l_record.entrp_id              := x.entrp_id;
     l_record.acc_id                := x.acc_id;
     l_record.account_status        := x.account_status;
     l_record.complete_flag         := x.complete_flag;
     l_record.account_status_meaning    := X.Status_meaning;          -- rprabu 9141 17/08/2020
     l_record.Enrolle_Type          := x.Enrolle_Type;                -- Added  By Rprabu For Ticket#9141 On 30/07/2020
     l_record.Enrolled_By           := x.Enrolled_By;                 -- Added  By Rprabu For Ticket#9141 On 30/07/2020
     l_record.resubmit_flag           := x.resubmit_flag;               -- Added by Jagggi for Ticket#10430 on 04/11/2021
     l_record.Signature_account_status := x.Signature_account_status;       -- Added by Swamy for Tiecket#11364(Broker)

     -- Added By Joshi for 10430.
     l_record.inactive_plan_flag := 'N';
     IF X.acc_id IS NOT NULL AND X.ACCOUNT_TYPE NOT IN ( 'SBS', 'CMP', 'RB','ACA') THEN
       FOR Y IN (  SELECT plan_type, MAX(plan_end_date) plan_end_date
                             FROM ACCOUNT A, BEN_PLAN_ENROLLMENT_SETUP B
                           WHERE A.ACC_ID = B.ACC_ID
                                AND A.ACC_ID =  x.acc_id
                                AND PLAN_TYPE  NOT  IN ('TRN','PKG','UA1')
                                AND A.account_type in ('FSA','HRA')
                     GROUP BY plan_type
                                UNION
                            SELECT   'TRN',  MAX( B.END_DATE) PLAN_END_DATE
                            FROM BEN_PLAN_RENEWALS B, ACCOUNT A
                            WHERE A.ACC_ID= B.ACC_ID
                                 AND B.ACC_ID =  x.acc_id
                                 AND A.ACCOUNT_TYPE in ( 'FSA', 'HRA')
                                 AND B.PLAN_TYPE  IN ('TRN','PKG','UA1')
                              GROUP BY B.ACC_ID
                                 UNION
                                 SELECT ACCOUNT_TYPE, MAX(plan_end_date) plan_end_date
                                    FROM ACCOUNT A, BEN_PLAN_ENROLLMENT_SETUP B
                                  WHERE A.ACC_ID = B.ACC_ID
                                      AND A.ACC_ID =  x.acc_id
                                      AND A.account_type not  in ('FSA','HRA')
                           GROUP BY ACCOUNT_TYPE
                            )
        LOOP

              -- Added code by Joshi for 11271.
              IF NVL(  x.resubmit_flag, 'N' ) = 'N'  THEN

                  If pc_account.get_account_type_from_entrp_id(x.entrp_id) = 'FORM_5500' THEN
                        -- For FORM5500 resubmit option is changed from 365 to 730 days as per Ticket#11131
                        If TRUNC(sysdate) - Y.plan_end_date  >=  730 THEN
                             l_record.inactive_plan_flag := 'Y';
                             l_record.complete_flag      := 0;
                        ELSE
                             l_record.inactive_plan_flag := 'N';
                             l_record.complete_flag     := 1;
                        END IF;
                  ELSE
                         IF ( SYSDATE - Y.plan_end_date)  <=  365 THEN
                             l_record.inactive_plan_flag := 'N';
                              l_record.complete_flag         := x.complete_flag;
                             EXIT; -- Added by Joshi for 10750
                         END IF;

                     -- Added by Joshi for 10750
                      l_record.inactive_plan_flag := 'Y';
                      l_record.complete_flag := 0;

                  END IF;
                END IF;


        END LOOP;
     END IF;
     PIPE ROW(l_record);

  END LOOP;

END get_er_not_enrolled_plans;

FUNCTION chk_all_product_enroll(p_tax_id IN VARCHAR2)
RETURN VARCHAR2
IS
  l_plans_enrolled NUMBER := 0;
  l_tot_products NUMBER := 0;

BEGIN
   SELECT count(*)
   INTO l_tot_products
   from ACCOUNT A,ENTERPRISE B
   where a.entrp_id = b.entrp_id
   and replace(b.entrp_code,'-') = replace(p_tax_id,'-');

   SELECT count(*)
   INTO l_plans_enrolled
   from ACCOUNT A,ENTERPRISE B
   where a.entrp_id = b.entrp_id
   and replace(b.entrp_code,'-') = replace(p_tax_id,'-')
   AND EXISTS(select * from ben_plan_enrollment_setup d
                where d.acc_id = a.acc_id);

IF l_tot_products = l_plans_enrolled THEN
  return 'Y';
ELSE
  return 'N';
END IF;


 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return 'N';

END chk_all_product_enroll;

FUNCTION get_products_er_online( p_user_id IN NUMBER)
RETURN accounts_t PIPELINED DETERMINISTIC
IS
  l_record accounts_row_t;
BEGIN
  pc_log.log_error('get_products:user_id ',p_user_id);
  FOR X IN ( SELECT emp_reg_type ,tax_id
             FROM   online_users
             WHERE  user_id = p_user_id)
  LOOP
     IF x.emp_reg_type IN ('5', '2') THEN
        FOR xx IN (SELECT  acc_num, account_type,account_status,acc_id,entrp_id,broker_id
                  from emp_OVERVIEW_V where ein=x.tax_id
                  and complete_flag = 1
                  and account_type IN ('HRA','FSA','HSA','COBRA','POP','ERISA_WRAP','FORM_5500'))
        LOOP
              l_record.acc_num := xx.acc_num;
              l_record.account_type := xx.account_type;
              l_record.account_status := xx.account_status;
              l_record.meaning := PC_LOOKUPS.GET_ACCOUNT_TYPE(xx.account_type);
              l_record.acc_id := xx.acc_id;
              l_record.entrp_id := xx.entrp_id;
              l_record.broker_id := xx.broker_id;
          PIPE ROW (l_record);
        END LOOP;
     ELSE
        FOR xx IN (SELECT  acc_num, account_type,account_status,acc_id,entrp_id,broker_id
                  from emp_OVERVIEW_V A
                  where A.ein=x.tax_id
                   and   A.account_type IN (SELECT ACCOUNT_TYPE FROM  USER_ROLE_ENTRIES B, SITE_NAVIGATION C
                                           WHERE B.USER_ID = p_user_id
                                           AND   B.SITE_NAV_ID = C.SITE_NAV_ID))
        LOOP
          l_record.acc_num := xx.acc_num;
          l_record.account_type := xx.account_type;
          l_record.account_status := xx.account_status;
          l_record.meaning := PC_LOOKUPS.GET_ACCOUNT_TYPE(xx.account_type);
          l_record.acc_id := xx.acc_id;
          l_record.entrp_id := xx.entrp_id;
          l_record.broker_id := xx.broker_id;

          PIPE ROW (l_record);

        END LOOP;
     END IF;

  END LOOP;

END get_products_er_online;

FUNCTION show_alert (p_user_id IN VARCHAR2)
RETURN VARCHAR2
IS
  l_new_user_alert VARCHAR2(10) := 'N';
  l_cnt NUMBER := 0;
  l_cnt_enrolled NUMBER := 0;
BEGIN
  --New User
  SELECT count(*)
  INTO l_cnt
  FROM ONLINE_USERS A,ENTERPRISE B ,ACCOUNT C
  where  a.user_id = p_user_id
  and a.tax_id = b.entrp_code
  and b.entrp_id = c.entrp_id
--  and c.account_status = 3
  and c.complete_flag <> 1
  and a.user_status = 'A'
  --and c.account_type NOT in ( 'HRA','FSA')--Remove it later when FSA/HRA are included, 01152017, removing
  and c.decline_date is NULL;

  IF l_cnt > 0 THEN --New users
    l_new_user_alert := 'Y';
  ELSE --Existing users
    IF l_cnt = 0 THEN
         SELECT count(*)
         INTO l_cnt_enrolled
         FROM LOOKUPS WHERE LOOKUP_NAME = 'ACCOUNT_TYPE'
         AND LOOKUP_CODE NOT IN ('CMP') -- 01152017, removing HRA/FSA
         and LOOKUP_CODE NOT IN (SELECT b.account_type
         FROM   ENTERPRISE E, ACCOUNT B ,online_users c
         WHERE  E.ENTRP_ID = B.ENTRP_ID
         and replace(c.tax_id,'-') = replace(e.entrp_code,'-')
         and    c.user_id = p_user_id );

       IF l_cnt_enrolled = 0 THEN  --All products enrolled
         l_new_user_alert := 'ALL';
       ELSE
         l_new_user_alert := 'N';
       END IF;
     END IF; --Existing users
    END IF;--Outer Loop

  return l_new_user_alert;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     l_new_user_alert := 'N';
     return l_new_user_alert;

END show_alert;
FUNCTION skip_now_func (P_tax_id IN VARCHAR2) RETURN roles_t PIPELINED DETERMINISTIC
IS
 l_record roles_row_t;
  l_acct_type VARCHAR2(100);
 l_acc_num VARCHAR2(100);
BEGIN
  FOR X IN ( SELECT COUNT(*) cnt
                ,sum(case when a.account_status = 3 then 1 else 0 end ) pending
               ,sum(case when a.account_status <> 3 then 1 else 0 end ) active_count
                     FROM  account a, enterprise b
                     WHERE replace(b.entrp_code,'-') = replace(p_tax_id,'-')
                     AND   a.entrp_id = b.entrp_id
                     AND   account_status <> 4 )
   LOOP


     IF X.pending >=1 and X.active_count = 0 THEN
      l_record.redirect_url := 'Accounts/Portfolio/newEREnroll';
     ELSIF  X.pending >=1 and X.active_count >1 THEN
      l_record.redirect_url := 'Accounts/Portfolio/';
     ELSIF X.pending >= 1 and X.active_count = 1 THEN

         SELECT a.account_type, a.acc_num
         INTO l_acct_type,l_acc_num
	       FROM  account a, enterprise b
	       WHERE replace(b.entrp_code,'-') = p_tax_id
         AND   a.entrp_id = b.entrp_id
         and account_status = 1 ;

           IF l_acct_type = 'HSA' THEN
	            l_record.redirect_url := 'Employers/Detail/EmployerDashboard/';
	         ELSIF  l_acct_type = 'HRA' THEN
	             l_record.redirect_url := 'HRA/Employers/EmployerDashboard/';
	         ELSIF  l_acct_type= 'FSA' THEN
	             l_record.redirect_url := 'FSA/Employers/EmployerDashboard/';
	         ELSIF  l_acct_type = 'COBRA' THEN
	            l_record.redirect_url := 'COBRA/Employers/EmployerDashboard/';
	         ELSIF  l_acct_type= 'ERISA_WRAP' THEN
	            l_record.redirect_url := 'ERISA/Employers/EmployerDashboard/';
	         ELSIF  l_acct_type = 'POP' THEN
	            l_record.redirect_url := 'POP/Employers/EmployerDashboard/';
	         ELSIF  l_acct_type= 'FORM_5500' THEN
	            l_record.redirect_url := 'Form5500/Employers/EmployerDashboard/';
	         ELSE l_record.redirect_url := 'Accounts/Portfolio/';
          END IF;

          l_record.nav_code := l_acc_num;
     END IF;
     PIPE ROW(l_record);
   END LOOP;


 END  skip_now_func ;
 FUNCTION get_pwd_recovery(p_user_name IN VARCHAR2) RETURN user_info_t PIPELINED DETERMINISTIC
IS
   e_user_exception         EXCEPTION;
   l_count                  NUMBER := 0;
   l_error_message          VARCHAR2(3200);
   l_login                  VARCHAR2(1) := 'N';
   l_loggedin               VARCHAR2(1) := 'N';
   l_skip_security          VARCHAR2(10) := 'N';
   l_no_of_registration     NUMBER := 0;
   l_record_t               user_info_row_t;
   l_user_id                NUMBER;
   l_no_accounts            NUMBER := 0;
BEGIN

   FOR X IN (SELECT *
               FROM online_users
              WHERE user_name = trim(p_user_name))
   LOOP

     pc_log.log_error('GET_USER_INFO_BY_UNAME','user_name '||p_user_name);

     l_count := l_count+1;
     l_record_t.user_id       := x.user_id;
     l_record_t.user_name     := p_user_name;
     l_record_t.error_status := 'S';
     l_record_t.user_type     := x.user_type;
     l_record_t.emp_reg_type  := x.emp_reg_type;
     l_record_t.tax_id        := x.tax_id;
     l_record_t.confirmed_flag  := NVL(x.confirmed_flag,'N');
     l_record_t.email    := x.email;
     l_record_t.acc_num    := x.find_key;
     l_record_t.locked_reason := x.locked_reason;
     l_record_t.first_time_pw_flag := x.first_time_pw_flag;


     l_record_t.pw_reminder_qut    := x.pw_question;
     l_record_t.pw_reminder_ans    := x.pw_answer;


     l_record_t.locked_account := 'N';

      IF   x.locked_reason IS NOT NULL
     THEN
          IF  x.failed_att >= 3 THEN
            IF (SYSDATE-to_date(X.locked_time,'YYYY-MM-DD HH24:MI:SS'))*1440 < 30 THEN
                l_error_message := 'Your account is temporarily suspended for 30 minutes for invalid login attempts.;;Please try again after the suspended time or contact Customer Service at 800-617-4729 during regular business hours.';
                l_record_t.locked_account := 'Y';
                RAISE  e_user_exception;
            ELSIF (SYSDATE-to_date(X.locked_time,'YYYY-MM-DD HH24:MI:SS'))*1440 >= 30 THEN
                l_record_t.locked_reason := null;

            END IF;
          END IF;
       END IF;
     -- all conditions passed , letting the user login

     pc_log.log_error('GET_USER_INFO_BY_UNAME','x.user_type '||x.user_type);



      l_user_id := x.user_id;

       FOR xx IN (
            SELECT otp_verified,verified_phone_type, verified_phone_number ,
                   remember_pc,pc_insure.get_eob_status(x.tax_id) eob_status
              FROM user_security_info
             WHERE user_id = x.user_id )
        LOOP
           l_record_t.otp_verified      := xx.otp_verified;
           l_record_t.verified_phone_type    := xx.verified_phone_type;
            l_record_t.verified_phone_number    := xx.verified_phone_number;
            l_record_t.remember_pc    := xx.remember_pc;
         END LOOP;



     PIPE ROW(l_record_t);
   END LOOP;

   IF l_count =  0 THEN
       l_error_message := '20008: The username you have entered is not found in our records. Please contact Customer Service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com.';

       RAISE  e_user_exception;
   END IF;


EXCEPTION

  WHEN e_user_exception THEN
    l_record_t.user_name := p_user_name;
    pc_log.log_error('GET_USER_INFO_BY_UNAME','l_error_message '||l_error_message);
    pc_log.log_error('GET_USER_INFO_BY_UNAME','redirect_url '||l_record_t.redirect_url );

  IF l_error_message IS NOT NULL THEN
     l_record_t.error_message := l_error_message;
     l_record_t.error_status := 'E';


  END IF;

   PIPE ROW(l_record_t);

 WHEN OTHERS THEN
   l_record_t.user_name := p_user_name;
   l_record_t.error_message := SQLERRM;
   pc_log.log_error('GET_USER_INFO_BY_UNAME',' l_record_t.error_message '|| l_record_t.error_message);

   l_record_t.error_status := 'E';



   PIPE ROW(l_record_t);

 END get_pwd_recovery;
 PROCEDURE verify_pwd_recovery(p_user_id       IN NUMBER
                             , p_user_type     IN VARCHAR2
                             , p_id_info       IN VARCHAR2
                             , x_error_status  OUT VARCHAR2
                             , x_error_message OUT VARCHAR2)
 IS
    l_verify VARCHAR2(1) := 'N';
 BEGIN
   x_error_status := 'S';
   FOR X IN (SELECT tax_id FROM online_users WHERE user_id = p_user_id
             AND    tax_id = p_id_info)
   LOOP
     l_verify := 'Y';
   END LOOP;
   IF l_verify = 'Y' THEN
      x_error_status := 'S';

   ELSE
      x_error_status := 'E';
      x_error_message := 'The information you''ve provided does not match the information on file. This recovery method will be disabled after 3 failed attempts, please check your entry and try again. If you feel you''ve received this message in error, please reach out to our Customer Service team at 800-617-4729 for assistance.';

   END IF;
 END verify_pwd_recovery;

  /*Ticket#6834 */

FUNCTION Get_Broker_To_User_Info
		(P_Acc_Num   IN VARCHAR2
        ,p_user_id   IN VARCHAR2  --- 8837 12/05/2020
     	,P_Broker_Id IN NUMBER
		,P_Is_Broker IN VARCHAR2)
RETURN user_info_t PIPELINED DETERMINISTIC
IS
   l_record_t  user_info_row_t;

 BEGIN

 IF p_is_broker = 'E' THEN

 -- Added by Joshi for 9902.
	FOR X In (SELECT a.*
                FROM ONLINE_USERS a , BROKER B
               WHERE UPPER(a.find_key) = UPPER(b.broker_lic)
                 AND b.broker_id = p_broker_id
                 AND a.user_id   = p_user_id
             )
	LOOP
     --l_record_t.user_id       := x.user_id;
         l_record_t.user_id        := p_user_id;
		 l_record_t.user_name      := x.user_name;
		 l_record_t.error_status   := 'S';
		 l_record_t.password       := x.password;
		 l_record_t.user_type      := x.user_type;
		 l_record_t.emp_reg_type   := x.emp_reg_type;
		 l_record_t.confirmed_flag := NVL(x.confirmed_flag,'N');
		 l_record_t.email           := x.email;
         l_record_t.locked_reason   := x.locked_reason;
		 l_record_t.first_time_pw_flag := x.first_time_pw_flag;
		 l_record_t.logged_in   := 'N';

     FOR Y IN ( SELECT A.acc_id, a.account_type, A.acc_num, l.description, e.entrp_code
                  FROM Account A, enterprise e, lookups l
                 WHERE a.acc_num = P_Acc_Num
                   AND a.entrp_id = e.entrp_id
                   AND a.account_type = l.lookup_code
                   AND l.lookup_name = 'ACCOUNT_TYPE')
     LOOP
       l_record_t.tax_id                    := y.entrp_code;
       l_record_t.acc_num                   := y.acc_num;   -- Joshi : 9902 x.find_key;
       l_record_t.no_of_accounts            := 1;
       l_record_t.account_type              := y.account_type;
       l_record_t.acc_type_description		:= y.description;
       l_record_t.acc_id                    := y.acc_id;
       l_record_t.portfolio_account         := 'N';

       IF y.account_type = 'HSA' THEN
          l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
			 ELSIF   y.account_type = 'HRA' THEN
			   l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
			 ELSIF   y.account_type = 'FSA' THEN
          l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
			  ELSIF   y.account_type = 'COBRA' THEN
          l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
			  ELSIF  y.account_type = 'POP' THEN
          l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
       ELSIF   y.account_type = 'FORM_5500' THEN
					l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
        ELSIF   y.account_type = 'ERISA_WRAP' THEN
					l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
		   END IF;
     END LOOP;

	--     l_record_t.security_setup := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id);
		 FOR ap In ( SELECT ap.allow_broker_enroll,ap.allow_broker_renewal,ap.allow_broker_invoice,
                            ap.allow_broker_Enroll_ee,ap.allow_broker_Enroll_rpts ,ap.allow_broker_ee,
                            ap.Allow_bro_upd_pln_Doc
			           FROM ACCOUNT_PREFERENCE ap
				      WHERE ap.acc_id = l_record_t.acc_id )

    LOOP
      l_record_t.allow_broker_enroll 		  := ap.allow_broker_enroll;
      l_record_t.allow_broker_renewal		  := ap.allow_broker_renewal;
      l_record_t.allow_broker_invoice		  := ap.allow_broker_invoice;
      l_record_t.allow_broker_Enroll_ee       := ap.allow_broker_Enroll_ee;
      l_record_t.allow_broker_Enroll_rpts     := ap.allow_broker_Enroll_rpts;
      l_record_t.allow_broker_ee              := ap.allow_broker_ee;
      l_record_t.Allow_bro_upd_pln_Doc        := ap.Allow_bro_upd_pln_Doc  ;

    END LOOP;

     IF l_record_t.tax_id IS NOT NULL THEN
        FOR Z in ( SELECT user_id
                     FROM online_users
                    WHERE tax_id = l_record_t.tax_id
                      AND emp_reg_type = 2
                      AND user_type = 'E'
					  AND user_status = 'A'   -- Added by Swamy for Ticket#INC31006 22/07/2025
                      AND ROWNUM < 2 )
        LOOP
            l_record_t.employer_user_id := z.user_id;
        END LOOP;
      END IF;

     IF l_record_t.allow_login IS NULL THEN
			l_record_t.allow_login := 'Y';
		 END IF;
      l_record_t.pw_reminder_qut   		 := x.pw_question;
      l_record_t.pw_reminder_ans   		 := x.pw_answer;
      l_record_t.locked_account    		 := 'N';
      PIPE ROW(l_record_t);

   END LOOP;

 ELSIF p_is_broker = 'B' THEN /* Back to Broker Dashboard */
       FOR X IN (SELECT a.* from ONLINE_USERS a , BROKER B
				  WHERE UPPER(a.find_key) = UPPER(b.broker_lic)
            		AND b.broker_id = p_broker_id
                    AND a.user_id = p_user_id ) ---8837 12/05/2020
    LOOP
        l_record_t.user_id       := x.user_id;
       l_record_t.user_name      := x.user_name;
       l_record_t.error_status   := 'S';
       l_record_t.password       := x.password;
       l_record_t.user_type      := x.user_type;
       l_record_t.emp_reg_type   := x.emp_reg_type;
       l_record_t.tax_id         := x.tax_id;
       l_record_t.confirmed_flag  := NVL(x.confirmed_flag,'N');
       l_record_t.email    := x.email;
       l_record_t.acc_num    := x.find_key;
       l_record_t.locked_reason := x.locked_reason;
       l_record_t.first_time_pw_flag := x.first_time_pw_flag;
       l_record_t.logged_in   := 'N';
       l_record_t.no_of_accounts := 1;
       l_record_t.account_type := '';
       --l_record_t.acc_id := x.acc_id;
       l_record_t.portfolio_account := 'N';

         l_record_t.redirect_url := 'Brokers/Detail/AccountManagement/' ; -- 'Brokers/Detail/BrokerDashboard/';
            FOR xX IN (SELECT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                         FROM broker a, person b
                        WHERE UPPER(a.broker_lic) = UPPER(x.find_key)
                          AND a.broker_id = b.pers_id)
            LOOP
                 l_record_t.display_name := xx.name;
             END LOOP;

	   	PIPE ROW(l_record_t);
	    END LOOP;

    ----------- 9527  04/11/2020
    /*
 ELSIF p_is_broker = 'G' THEN   Back to Broker Dashboard
       FOR X IN (select  a.user_id, a.user_name, a.password, a.user_type, a. emp_reg_type,   b.ga_lic ,a.tax_id ,
                         a.first_time_pw_flag, a.locked_reason, a.find_key ,   a.email, a.confirmed_flag , b.agency_name
                 FROM  ONLINE_USERS a , General_agent  B
				   WHERE  a.find_key = b.ga_Lic
            		AND  b.ga_id = p_broker_id
                    AND a.user_id = p_user_id )
    LOOP
        l_record_t.user_id       := x.user_id;
       l_record_t.user_name      := x.user_name;
       l_record_t.error_status   := 'S';
       l_record_t.password       := x.password;
       l_record_t.user_type      := x.user_type;
       l_record_t.emp_reg_type   := x.emp_reg_type;
        l_record_t.tax_id         := x.tax_id;
       l_record_t.confirmed_flag  := NVL(x.confirmed_flag,'N');
       l_record_t.email    := x.email;
       l_record_t.acc_num    := x.find_key;
       l_record_t.locked_reason := x.locked_reason;
       l_record_t.first_time_pw_flag := x.first_time_pw_flag;
       l_record_t.logged_in   := 'N';
       l_record_t.no_of_accounts := 1;
       l_record_t.account_type := '';
       l_record_t.portfolio_account := 'N';
        l_record_t.redirect_url := 'GA/Detail/AccountManagement/' ; -- confirm on this with PHP team and replace this url 9527  04/11/2020
         l_record_t.display_name := x.agency_name ;
    	PIPE ROW(l_record_t);
	    END LOOP;  */

  END IF;/* Broker Employer End If */
END Get_Broker_To_User_Info;

-- 9132 rprabu added to identify the broker is main or sub broker account
 Function Is_main_online_broker( p_user_id number )  Return Varchar2
Is
l_broker_lic Varchar2(100) ;
L_user_id    Number  ;
begin
For  I in (Select find_key From online_users where user_id = p_user_id )
 Loop
    l_broker_lic := I.find_key;
  End Loop;

  select min (user_id)
    Into L_user_id
    From online_users
   Where find_key=l_broker_lic;

 If L_user_id= p_user_id Then
    Return 'Y';
 Else
    Return 'N';
 End if;

End Is_main_online_broker;

 -- Added by Jaggi #9771
 PROCEDURE UPDATE_LOGIN_INFO (P_USER_ID NUMBER ,P_IP_ADDESS IN VARCHAR2)
 IS
 BEGIN
    UPDATE ONLINE_USERS
       SET LAST_LOGIN    = TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS')
          ,LAST_LOGIN_IP = P_IP_ADDESS
     WHERE USER_ID       = P_USER_ID;
EXCEPTION
 WHEN OTHERS THEN
    pc_log.log_error('UPDATE_LOGIN_INFO',' error_message '|| SQLERRM(SQLCODE));
END UPDATE_LOGIN_INFO;

-- Added By Jaggi #9731
FUNCTION GET_USER_TYPE (P_USER_ID IN NUMBER)
 RETURN VARCHAR2
 IS
  L_USER_TYPE VARCHAR2(1);
BEGIN
  FOR X IN ( SELECT USER_TYPE
               FROM ONLINE_USERS
              WHERE USER_ID = P_USER_ID)
   LOOP
         L_USER_TYPE := X.USER_TYPE;
   END LOOP;
   RETURN L_USER_TYPE;
END GET_USER_TYPE;

-- Added by Jaggi for ticket. #9804
PROCEDURE SAM_USERS_PWD_HISTORY (P_USER_ID IN NUMBER, P_PASSWORD IN VARCHAR2)
 IS
 BEGIN
   INSERT INTO SAM_USERS_PWD_HISTORY
              (USER_ID
              ,PASSWORD
              ,CREATED_BY
              ,CREATION_DATE)
        VALUES(P_USER_ID
              ,P_PASSWORD
              ,P_USER_ID
              ,SYSDATE);
EXCEPTION
 WHEN OTHERS THEN
    pc_log.log_error('SAM_USERS_PWD_HISTORY',' error_message '|| SQLERRM(SQLCODE));
END SAM_USERS_PWD_HISTORY;

-- Added by Joshi #9902
FUNCTION enroll_new_acct_by_ein (p_tax_id IN VARCHAR2)
RETURN VARCHAR2
IS
 l_new_user VARCHAR2(10) := 'N';
 l_count NUMBER := 0;
BEGIN
 SELECT COUNT(*)
   INTO l_count
   FROM ONLINE_USERS A,ENTERPRISE B ,ACCOUNT C
  WHERE a.tax_id = p_tax_id
    AND a.tax_id = b.entrp_code
    AND b.entrp_id = c.entrp_id
    AND c.account_status = 3
    AND a.user_status = 'A' ;

  IF l_count > 0 THEN
      return 'Y';
  END IF;

  l_count := 0;

 SELECT count(*)
   INTO l_count
   FROM LOOKUPS
  WHERE LOOKUP_NAME = 'ACCOUNT_TYPE'
    AND LOOKUP_CODE NOT IN ('CMP','HRA','FSA')
    AND LOOKUP_CODE NOT IN (SELECT b.account_type
                              FROM ENTERPRISE E, ACCOUNT B ,ONLINE_USERS OU
                             WHERE ou.tax_id = p_tax_id
                               AND E.ENTRP_ID = B.ENTRP_ID
                               AND e.entrp_code = OU.TAX_ID
                               AND ou.emp_reg_type <> '5');

 IF l_count > 0 THEN
    return 'Y';
 ELSE
    return 'N';
END IF;

EXCEPTION
   WHEN TOO_MANY_ROWS THEN
    l_new_user := 'Y';
    return l_new_user;

  WHEN OTHERS THEN
     return 'N';

END enroll_new_acct_by_ein;

-- Added by Joshi #9902
FUNCTION get_nav_list_v2
( p_user_id     IN NUMBER
,p_account_type IN VARCHAR2
,p_auth_req_id  IN NUMBER
,p_tax_id       IN VARCHAR2 DEFAULT NULL)  RETURN pc_users.roles_t PIPELINED DETERMINISTIC

IS
 l_record  pc_users.roles_row_t;
BEGIN
    pc_log.log_error('pc_users.get_nav_list_v2 begin','p_user_id '||p_user_id||' p_account_type :='||p_account_type||'p_auth_req_id :='||p_auth_req_id||'p_tax_id :='||p_tax_id); 
  FOR X IN (SELECT tax_id, emp_reg_type, user_type
              FROM online_users
             WHERE user_id = p_user_id )
  LOOP
    IF x.user_type = 'E' THEN

      FOR  ER_NAV  in  (
        SELECT  WEB_NAV_URL,   NAV_DESCRIPTION,     WEB_NAV_CODE,seq_no
        FROM (
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM SITE_NAVIGATION
               WHERE ACCOUNT_TYPE = p_account_type
                 AND STATUS = 'A'
                 AND Portal_type = 'EMPLOYER'
                 AND conditional_flag = 'N' AND x.emp_reg_type IN ('2') -- Added by jaggi - role 5'id removed for #9829
               UNION
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM SITE_NAVIGATION s, USER_ROLE_ENTRIES ur
               WHERE s.ACCOUNT_TYPE = p_account_type
                 AND s.STATUS = 'A'
                 AND s.site_nav_id = ur.site_nav_id
                 AND ur.user_id = p_user_id
                 AND Portal_type = 'EMPLOYER'
                 AND s.conditional_flag = 'N' AND x.emp_reg_type NOT IN ('2') -- Added by jaggi - role 5'id removed for #9829
               UNION
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM SITE_NAVIGATION s
               WHERE nav_code  in (  'USER_PROFILE',  'MESSAGES')
                 AND Portal_type = 'EMPLOYER'
                 AND PC_USERS.enroll_new_acct(p_user_id) = 'Y'
               UNION
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM SITE_NAVIGATION s
               WHERE nav_code  =  'PRODUCTS'
                 AND Portal_type = 'EMPLOYER'
                 AND PC_USERS.enroll_new_acct(p_user_id) = 'Y'
                 AND x.emp_reg_type <> ('5')
               UNION
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM ( SELECT  account_type
                             , CASE WHEN account_type IN ('HRA','FSA') THEN
                                    Pc_Web_Er_Renewal.Emp_Plan_Renewal_Disp(Xx.Acc_Id)
                                  WHEN  account_type = 'COBRA' THEN
                                    Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Cobra(Xx.Acc_Id)
                                  WHEN account_type = 'POP' THEN
                                    Nvl(Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Pop(xx.acc_id,'POP'), 'N') -- 8837
                                  WHEN account_type = 'FORM_5500' THEN
                                    Pc_Web_Compliance.Emp_Plan_Renwl_Disp_Form_5500(xx.acc_id)
                                  WHEN account_type = 'ERISA_WRAP' THEN
                                    Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Erisa(xx.acc_id)
                               END renewed
                          FROM emp_overview_v xx
                         WHERE EIN = p_tax_id
                           AND account_type = p_account_type
                           AND account_type IN ('HRA','FSA','COBRA','ERISA_WRAP','FORM_5500','POP')
                      ) renewal, site_Navigation s
               WHERE renewal.account_type = s.account_type
                 AND renewal.renewed = 'Y'
                 AND s.PORTAL_TYPE = 'EMPLOYER'
                 AND s.nav_code = 'RENEWAL'
                 AND s.conditional_flag = 'Y'
                 AND x.emp_reg_type <> ('5')
            UNION
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM Site_Navigation s
               WHERE nav_code not in ('RENEWAL','PRODUCTS','PLAN_AMENDMENT')
                 AND Portal_type = 'EMPLOYER'
                 AND conditional_flag = 'Y' AND x.emp_reg_type IN ('2') -- Added by jaggi - role 5'id removed for #9829
            UNION
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM Site_Navigation s
               WHERE nav_code = 'EDI_FEEDS'
                 AND Portal_type = 'EMPLOYER'
                 AND x.emp_reg_type IN ('2') -- Added by jaggi - role 5'id removed for #9829
                 AND pc_account.get_edi_flag(p_tax_id) = 'Y'
             -- added by jaggi #10742
            UNION
              SELECT Web_Nav_Url,   Nav_Description,     Web_Nav_Code,Seq_No
                FROM Site_Navigation s
               WHERE ACCOUNT_TYPE = p_account_type
                 AND nav_code = 'PLAN_AMENDMENT'
                 AND Portal_type = 'EMPLOYER'
                 AND conditional_flag = 'Y' AND x.emp_reg_type IN ('2')
                 AND EXISTS (SELECT * from pc_employer_enroll_compliance.get_amendment_plans(p_tax_id) WHERE ACCOUNT_TYPE = p_account_type)
              )
              ORDER BY seq_no ASC)
      LOOP
          l_Record.Nav_Code        := Er_Nav.Web_Nav_Code;
          l_Record.Redirect_Url    := Er_Nav.Web_Nav_Url;
          l_Record.Url_Description := Er_Nav.Nav_Description;
          PIPE ROW (l_record);
      END LOOP;
    ELSIF x.user_type = 'B' AND P_AUTH_REQ_ID IS NOT NULL THEN
      FOR NAV_DETAILS  in  (
              SELECT  WEB_NAV_URL,NAV_DESCRIPTION,WEB_NAV_CODE
                FROM (
                        SELECT s.Site_Nav_Id,Web_Nav_Url,Nav_Description,Web_Nav_Code,Seq_No,Nav_Code
                          FROM Site_Navigation s,USER_ROLE_ENTRIES B
                         WHERE S.ACCOUNT_TYPE = p_account_type
                          AND S.STATUS = 'A'
                          AND S.Portal_type = 'BROKER_EMPLOYER'
                          AND S.conditional_flag = 'N'
                          AND S.SITE_NAV_ID = B.SITE_NAV_ID
                          AND B.USER_ID= p_user_id
                          AND B.AUTHORIZE_REQ_ID = p_auth_req_id
               UNION
              SELECT Site_Nav_Id,Web_Nav_Url,Nav_Description,Web_Nav_Code,Seq_No,Nav_Code
                FROM Site_Navigation
               WHERE web_nav_code In ( 'employer_dashboard' , 'eeSearch', 'enroll_npm' , 'standard_report',  'disbursementreport' , 'plans' , 'subsidy_create'  ) ---- 'eeSearch',,standard_report, 'enroll_npm' added rprabu 13/01/2023
                 AND account_type = p_account_type       ---  'disbursementreport' , 'plans' , 'edi_feeds' added in above statement by rprabu 25/01/2023   subsidy_create added by rprabu on 06/07/2023 for subsidy
                 AND Portal_type = 'BROKER_EMPLOYER'
               UNION -- Added by Joshi for 12705. broker should be allowed to enroll employee only when account is active
              SELECT Site_Nav_Id,Web_Nav_Url,Nav_Description,Web_Nav_Code,Seq_No,Nav_Code
                FROM Site_Navigation 
               WHERE Web_Nav_Code in ('employees','bulkenrollment','employer_reports','hsa_invoicing') 
                 AND Portal_type = 'BROKER_EMPLOYER'
                 AND account_type = p_account_type 
                 and p_Account_type = 'HSA'
                 AND pc_users.enable_employer_tab(p_auth_req_id,p_user_id) = 'Y'
               UNION  
              SELECT s.Site_Nav_Id,Web_Nav_Url,Nav_Description,Web_Nav_Code,Seq_No,Nav_Code
                FROM Site_Navigation s,USER_ROLE_ENTRIES B
               WHERE S.ACCOUNT_TYPE = p_account_type
                 AND S.STATUS = 'A'
                 AND S.Portal_type = 'BROKER_EMPLOYER'
                 AND nav_code = 'PRODUCTS'
                 AND Pc_Users.enroll_new_acct_by_ein(p_tax_id) = 'Y'
                 AND S.conditional_flag = 'Y'
                 AND S.SITE_NAV_ID = B.SITE_NAV_ID
                 AND B.USER_ID= p_user_id
                 AND B.AUTHORIZE_REQ_ID = p_auth_req_id
               UNION
              SELECT  s.Site_Nav_Id,   Web_Nav_Url,   Nav_Description,     Web_Nav_Code,       Seq_No,  Nav_Code
                FROM (SELECT account_type
                            ,CASE WHEN account_type IN ('HRA','FSA') THEN
                                    Pc_Web_Er_Renewal.Emp_Plan_Renewal_Disp(xx.acc_id)
                                  WHEN  account_type = 'COBRA' THEN
                                    Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Cobra(xx.acc_id)
                                  WHEN account_type = 'POP' THEN
                                    Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Pop(xx.acc_id,'POP')
                                  WHEN account_type = 'FORM_5500' THEN
                                    Pc_Web_Compliance. Emp_Plan_Renwl_Disp_Form_5500(xx.acc_id)
                                  WHEN account_type = 'ERISA_WRAP' THEN
                                    Pc_Web_Compliance.Emp_Plan_Renewal_Disp_Erisa(xx.acc_id)
                              END renewed
                        FROM emp_overview_v xx
                       WHERE Ein = p_tax_id
                         AND account_type = p_account_type
                         AND account_type IN ('HRA','FSA','COBRA','ERISA_WRAP','FORM_5500','POP')
              ) renewal, SITE_NAVIGATION s,USER_ROLE_ENTRIES B
               WHERE renewal.account_type = s.account_type
                 AND renewal.renewed = 'Y'
                 AND s.Portal_Type = 'BROKER_EMPLOYER'
                 AND s.nav_code = 'renewal'
                 And s.conditional_flag = 'Y'
                 AND S.SITE_NAV_ID = B.SITE_NAV_ID
                 AND B.USER_ID= p_user_id
                 AND B.AUTHORIZE_REQ_ID = p_auth_req_id
              ORDER BY seq_no ASC)
              )
      LOOP
        l_Record.Nav_Code           := NAV_DETAILS.Web_Nav_Code ;
        l_Record.Redirect_Url       := NAV_DETAILS.Web_Nav_Url ;
        l_Record.Url_Description    := NAV_DETAILS.Nav_Description ;
        PIPE ROW (l_record);
      END LOOP;
    ELSIF x.user_type IN ('G','B') AND P_AUTH_REQ_ID IS NULL THEN -- 8890 rprabu 17/06/2020

        l_Record.Nav_Code        :=  null;
        l_Record.Redirect_Url    := Null;
        l_Record.Url_Description := null;
      FOR Broker_Nav  In  (
        SELECT    Web_Nav_Url,Nav_Description,Web_Nav_Code , seq_no
          FROM (
                SELECT WEB_NAV_URL,NAV_DESCRIPTION,WEB_NAV_CODE , seq_no
                  FROM SITE_NAVIGATION
                 WHERE STATUS = 'A'
                   AND portal_type =  decode(x.user_type, 'B', 'BROKER',  'G' , 'GA' )
                   AND x.emp_reg_type IN ('5','2')
                 UNION
                SELECT WEB_NAV_URL,NAV_DESCRIPTION,WEB_NAV_CODE  , seq_no
                  FROM SITE_NAVIGATION s, USER_ROLE_ENTRIES ur
                 WHERE s.STATUS = 'A'
                   AND s.site_nav_id = ur.site_nav_id
                   AND ur.user_id = p_user_id
                   AND portal_type =  decode(x.user_type, 'B', 'BROKER',  'G' , 'GA' )
                   AND x.emp_reg_type NOT IN ('5','2') )
      ORDER BY seq_no ASC)
      LOOP
          l_Record.Nav_Code        := Broker_Nav.Web_Nav_Code;
          l_Record.Redirect_Url    := Broker_Nav.Web_Nav_Url;
          l_Record.Url_Description := Broker_Nav.Nav_Description;
          PIPE ROW (l_record);
      END LOOP;
    END IF;
  END LOOP;
END get_nav_list_v2;

-- Added by Jaggi #11368
FUNCTION Get_Ga_To_User_Info
		(P_Acc_Num  IN VARCHAR2,
         p_user_id  IN VARCHAR2,
     	 P_GA_Id    IN NUMBER)
RETURN user_info_t PIPELINED DETERMINISTIC
IS
   l_record_t user_info_row_t;

 BEGIN
pc_log.log_error('Get_ga_To_User_Info','P_GA_Id :='||P_GA_Id||'p_user_id :='||p_user_id);

 -- Added by Joshi for 9902.
	FOR X In ( SELECT A.* FROM Online_Users A , General_Agent G
    	        WHERE UPPER(A.FIND_KEY) = UPPER(G.GA_LIC)
        		  AND G.GA_ID = P_GA_Id
                  AND A.USER_ID = P_USER_ID
				)
	LOOP
         l_record_t.user_id             := p_user_id;
		 l_record_t.user_name           := x.user_name;
		 l_record_t.error_status        := 'S';
		 l_record_t.password            := x.password;
		 l_record_t.user_type           := x.user_type;
		 l_record_t.emp_reg_type        := x.emp_reg_type;
		 l_record_t.confirmed_flag      := NVL(x.confirmed_flag,'N');
		 l_record_t.email               := x.email;
         l_record_t.locked_reason       := x.locked_reason;
		 l_record_t.first_time_pw_flag  := x.first_time_pw_flag;
		 l_record_t.logged_in           := 'N';

         FOR Y IN ( SELECT A.acc_id, A.account_type, A.acc_num, L.DESCRIPTION, E.entrp_code
                      FROM ACCOUNT A, ENTERPRISE E, lookups L
                     WHERE A.acc_num = p_acc_num
                       AND A.entrp_id = E.entrp_id
                       AND A.account_type = L.lookup_code
                       AND L.lookup_name = 'ACCOUNT_TYPE')
         LOOP
           l_record_t.tax_id                    := y.entrp_code;
           l_record_t.acc_num                   := y.acc_num;
           l_record_t.no_of_accounts            := 1;
           l_record_t.account_type              := y.account_type;
           l_record_t.acc_type_description		:= y.description;
           l_record_t.acc_id                    := y.acc_id;
           l_record_t.portfolio_account := 'N';

           IF y.account_type = 'HSA' THEN
              l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                 ELSIF   y.account_type = 'HRA' THEN
                   l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                 ELSIF   y.account_type = 'FSA' THEN
              l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                  ELSIF   y.account_type = 'COBRA' THEN
              l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                  ELSIF  y.account_type = 'POP' THEN
              l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
           ELSIF   y.account_type = 'FORM_5500' THEN
                        l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
            ELSIF   y.account_type = 'ERISA_WRAP' THEN
                        l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
               END IF;
         END LOOP;

         FOR AP IN ( SELECT AP.allow_broker_enroll,AP.allow_broker_renewal,AP.allow_broker_invoice,
                            AP.allow_broker_enroll_ee,AP.allow_broker_enroll_rpts ,AP.allow_broker_ee,
                            AP.allow_bro_upd_pln_doc
                       FROM account_preference AP
                      WHERE AP.acc_id = l_record_t.acc_id )

          LOOP
            l_record_t.allow_broker_enroll 		  := ap.allow_broker_enroll;
            l_record_t.allow_broker_renewal		  := ap.allow_broker_renewal;
            l_record_t.allow_broker_invoice		  := ap.allow_broker_invoice;
            l_record_t.allow_broker_Enroll_ee     := ap.allow_broker_Enroll_ee;
            l_record_t.allow_broker_Enroll_rpts   := ap.allow_broker_Enroll_rpts;
            l_record_t.allow_broker_ee            := ap.allow_broker_ee;
            l_record_t.Allow_bro_upd_pln_Doc      := ap.Allow_bro_upd_pln_Doc;

          END LOOP;

         IF l_record_t.tax_id IS NOT NULL THEN
            FOR z IN ( SELECT user_id
                         FROM online_users
                        WHERE tax_id = l_record_t.tax_id
                          AND emp_reg_type = 2
                          AND user_type = 'E'
                          AND ROWNUM < 2 )
            LOOP
                l_record_t.employer_user_id := z.user_id;
            END LOOP;
          END IF;

         IF l_record_t.allow_login IS NULL THEN
                l_record_t.allow_login := 'Y';
         END IF;
          l_record_t.pw_reminder_qut   		 := x.pw_question;
          l_record_t.pw_reminder_ans   		 := x.pw_answer;
          l_record_t.locked_account    		 := 'N';
          PIPE ROW(l_record_t);

   END LOOP;

END Get_Ga_To_User_Info;

-- Added by Joshi for 12705
FUNCTION enable_employer_tab(p_auth_req_id IN NUMBER, p_user_id IN NUMBER)
  RETURN VARCHAR2
IS
  l_count NUMBER := 0;
BEGIN
    FOR X IN ( SELECT COUNT(*) CNT 
                 FROM ACCOUNT A, ER_PORTAL_AUTHORIZATIONS ER
                WHERE A.ACC_ID = ER.ACC_ID 
                  AND ER.AUTHORIZE_REQ_ID = P_AUTH_REQ_ID
                  AND A.ACCOUNT_STATUS = 1
                  AND ER.USER_ID = P_USER_ID )
    LOOP
        l_count := x.cnt;
    END LOOP;
    IF l_count > 0 THEN
        RETURN 'Y' ;
    ELSE 
        RETURN 'N' ;
    END IF;

END enable_employer_tab;

 END PC_USERS;


