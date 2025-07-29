create or replace package samqa.pc_users is
    type user_info_row_t is record (
            user_id                  number(10),
            user_name                varchar2(255),
            password                 varchar2(255),
            site_key                 varchar2(1000),
            site_image               varchar2(255),
            user_type                varchar2(30),
            emp_reg_type             number(1),
            pw_question1             varchar2(255),
            pw_answer1               varchar2(255),
            pw_question2             varchar2(255),
            pw_answer2               varchar2(255),
            pw_question3             varchar2(255),
            pw_answer3               varchar2(255),
            remember_pc              varchar2(255),
            no_of_accounts           number,
            tax_id                   varchar2(255),
            acc_num                  varchar2(255),
            account_type             varchar2(255),
            acc_id                   varchar2(255),
            eob_status               varchar2(255),
            change_password          varchar2(1),
            sec_grace_days           number,
            skip_security            varchar2(1),
            sec_exist                varchar2(1),
            portfolio_account        varchar2(1),
            confirmed_flag           varchar2(1),
            redirect_url             varchar2(255),
            display_name             varchar2(255),
            password_sent            varchar2(255),
            allow_login              varchar2(255),
            error_message            varchar2(1000),
            error_status             varchar2(10),
            locked_account           varchar2(10),
            pw_reminder_qut          varchar2(255),
            pw_reminder_ans          varchar2(255),
            email                    varchar2(255),
            sso_user                 varchar2(255),
            locked_reason            varchar2(255),
            first_time_pw_flag       varchar2(1),
            logged_in                varchar2(1),
            security_setup           varchar2(1),
            otp_verified             varchar2(1),
            verified_phone_number    varchar2(255),
            verified_phone_type      varchar2(30),
            verified_email           varchar2(100),
            number_to_be_verified    varchar2(255),
            show_modal_window        varchar2(1),
            allow_broker_renewal     varchar2(2),  /*Ticket#6834 */
            allow_broker_enroll      varchar2(2),
            allow_broker_invoice     varchar2(2),
            acc_type_description     varchar2(100),
            allow_broker_enroll_ee   varchar2(2), --- 7781 added by rprabu on 17/05/2019
            allow_broker_enroll_rpts varchar2(2), --- 7781 added by rprabu on 17/05/2019
            allow_broker_ee          varchar2(2), --- 7781 added by rprabu on 17/05/2019
            show_td_ameritrade_page  varchar2(1),    --- Added by Joshi for 6596
            allow_bro_upd_pln_doc    varchar2(3),   --- Ticket#8728  added by rprabu on 18/02/2020
            employer_user_id         number,        --- Added by Joshi for 9902
            status                   varchar2(20)   -- Added by Jaggi #11090 on 05/10/2022
    );
    type user_info_t is
        table of user_info_row_t;
    type user_roles_row_t is record (
            site_nav_id     number,
            user_id         number,
            account_type    varchar2(30),
            nav_description varchar2(255)
    );
    type user_roles_t is
        table of user_roles_row_t;
    type accounts_row_t is record (
            acc_num                  varchar2(30),
            account_type             varchar2(30),
            meaning                  varchar2(255),
            account_type_meaning     varchar2(255),
            acc_balance              number,
            account_status           varchar2(30),
            account_status_meaning   varchar2(100)      ------rprabu 9141 17/08/2020
            ,
            complete_flag            varchar2(1),
            plan_count               number,
            acc_id                   number,
            entrp_id                 number,
            broker_id                number,
            decline_date             date   -- Added by Swamy for Ticket#8949);
            ,
            enrolle_type             varchar(30)   -- Added  By Rprabu For Ticket#9141 On 29/07/2020
            ,
            enrolled_by              number     -- Added  by rprabu for Ticket#9141    on 29/07/2020
            ,
            show_account_online      varchar2(1)  -- Added  by Swamy for Ticket#9332 on 06/11/2020
            ,
            resubmit_flag            varchar2(1)   -- Added  by Jaggi for Ticket#10430 on 04/11/2021
            ,
            inactive_plan_flag       varchar2(1)     -- Added  by Joshi for Ticket#10430 on 04/11/2021
            ,
            signature_account_status number              -- Added by Swamy for Tiecket#11364(Broker)
    );
    type accounts_t is
        table of accounts_row_t;
    type roles_row_t is record (
            nav_code        varchar2(30),
            redirect_url    varchar2(255),
            url_description varchar2(255)
    );
    type roles_t is
        table of roles_row_t;
    type user_detail_row_t is record (
            user_name      varchar2(255),
            email          varchar2(255),
            user_type      varchar2(30),
            confirmed_flag varchar2(1),
            registered     varchar2(1),
            name           varchar2(30),
            account_type   varchar2(30),
            acc_num        varchar2(30),
            enrollment_id  number,
            employer_id    varchar2(30)
    );
    type user_det_t is
        table of user_detail_row_t;
    procedure insert_users (
        p_user_name      in varchar2,
        p_password       in varchar2,
        p_user_type      in varchar2,
        p_emp_reg_type   in varchar2 default null,
        p_find_key       in varchar2,
        p_locked_time    in varchar2 default null,
        p_succ_access    in number default null,
        p_last_login     in varchar2 default null,
        p_failed_att     in number default null,
        p_failed_ip      in varchar2 default null,
        p_create_pw      in varchar2 default null,
        p_change_pw      in varchar2 default null,
        p_email          in varchar2,
        p_pw_question    in varchar2,
        p_pw_answer      in varchar2,
        p_confirmed_flag in varchar2 default 'N',
        p_tax_id         in varchar2 default null,
        x_user_id        out varchar2,
        x_return_status  out varchar2,
        x_error_message  out varchar2,
        p_user_id        in number default null
    );

    procedure insert_contact_user (
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_type          in varchar2,
        p_emp_reg_type       in varchar2 default null,
        p_find_key           in varchar2,
        p_locked_time        in varchar2 default null,
        p_succ_access        in number default null,
        p_last_login         in varchar2 default null,
        p_failed_att         in number default null,
        p_failed_ip          in varchar2 default null,
        p_create_pw          in varchar2 default null,
        p_change_pw          in varchar2 default null,
        p_email              in varchar2,
        p_pw_question        in varchar2,
        p_pw_answer          in varchar2,
        p_confirmed_flag     in varchar2 default 'N',
        p_tax_id             in varchar2 default null,
        p_first_time_pw_flag in varchar2 default 'N',
        x_user_id            out varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure update_users (
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_user_type     in varchar2,
        p_emp_reg_type  in varchar2 default null,
        p_find_key      in varchar2,
        p_email         in varchar2,
        p_pw_question   in varchar2,
        p_pw_answer     in varchar2,
        p_user_id       in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure delete_users (
        p_contact_user_id in varchar2,
        p_user_id         in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    function check_user_locked (
        p_user_name in varchar2
    ) return varchar2;

    function get_email (
        p_acc_num in varchar2,
        p_acc_id  in number,
        p_pers_id in number
    ) return varchar2;

    function validate_user (
        p_tax_id       in varchar2,
        p_acc_num      in varchar2,
        p_user_type    in varchar2,
        p_emp_reg_type in varchar2,
        p_user_name    in varchar2,
        p_password     in varchar2,
        p_user_id      in number default null
    ) return varchar2;

    function get_email_from_user_id (
        p_user_id in number
    ) return varchar2;

    function get_find_key (
        p_tax_id       in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return varchar2;

    function get_user (
        p_tax_id       in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return number;

    function get_user_name (
        p_user_id in number
    ) return varchar2;

    function get_user_id (
        p_user_name in varchar2
    ) return number;

    function get_user_count (
        p_tax_id       in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return number;

    function check_user_registered (
        p_tax_id    in varchar2,
        p_user_type in varchar2
    ) return varchar2;

    function is_active_user (
        p_tax_id    in varchar2,
        p_user_type in varchar2
    ) return varchar2;

    function is_portfolio_account (
        p_ssn in varchar2
    ) return varchar2;

    function check_find_key (
        p_tax_id       in varchar2,
        p_acc_num      in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return number;

    function is_confirmed (
        p_tax_id    in varchar2,
        p_user_type in varchar2
    ) return varchar2;

    function is_user_existing (
        p_user_name in varchar2
    ) return varchar2;

    function is_email_registered (
        p_tax_id in varchar2,
        p_email  in varchar2
    ) return varchar2;

    procedure reactivate_registration (
        p_acc_num in varchar2 default null,
        p_ssn     in varchar2 default null
    );

    procedure reactivate_er_registration (
        p_acc_num         in varchar2 default null,
        p_ein             in varchar2 default null,
        p_contact_user_id in number default null,
        p_user_id         in number default null
    );

    procedure inactivate_registration (
        p_acc_num         in varchar2 default null,
        p_user_id         in number default null,
        p_contact_user_id in number default null,
        p_user_name       in varchar2 default null
    );

    procedure lock_user (
        p_user_id     in number,
        p_lock_reason in varchar2,
        p_ip_address  in varchar2
    );

    procedure lock_user_with_ssn (
        p_ssn         in varchar2,
        p_lock_reason in varchar2,
        p_ip_address  in varchar2
    );

    procedure unlock_user (
        p_user_name in varchar2,
        p_password  in varchar2
    );

    function validate_ee_reg (
        p_acc_num    in varchar2,
        p_tax_id     in varchar2,
        p_user_name  in varchar2,
        p_birth_date in varchar2
    ) return varchar2;

    function validate_er_reg (
        p_acc_num   in varchar2,
        p_tax_id    in varchar2,
        p_user_name in varchar2,
        p_zip_code  in varchar2
    ) return varchar2;

    function get_user_info (
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_skip_security in varchar2 default 'N',
        p_referrer      in varchar2 -- anticipating for future login request
        ,
        p_sso_user      in varchar2
    ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
     return user_info_t
        pipelined
        deterministic;

    function get_user_info_v2 (
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_skip_security in varchar2 default 'N',
        p_referrer      in varchar2 -- anticipating for future login request
        ,
        p_sso_user      in varchar2
    ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
     return user_info_t
        pipelined
        deterministic;

    procedure reset_password (
        p_user_name in varchar2,
        p_password  in varchar2,
        p_user_id   in number
    );

    procedure create_role_entries (
        p_contact_user_id  in number,
        p_role_entries     in pc_online_enrollment.varchar2_tbl,
        p_user_id          in number,
        p_role_id          in number,
        p_authorize_req_id in number	-- 9902 added by Joshi
        ,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure set_password (
        p_user_name   in varchar2,
        p_password    in varchar2,
        p_pw_question in varchar2,
        p_pw_answer   in varchar2
    );

    function get_user_permissions (
        p_user_id   in number,
        p_role_type in number
    ) return user_roles_t
        pipelined
        deterministic;

    function get_permissions (
        p_user_id   in number,
        p_role_type in number
    ) return user_roles_t
        pipelined
        deterministic;

    function get_forgotten_user (
        p_user_name in varchar2,
        p_find_key  in varchar2,
        p_email     in varchar2
    ) return user_info_t
        pipelined
        deterministic;

    procedure confirm_registration (
        p_user_name     in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function enroll_acc_exists (
        p_tax_id in varchar2
    ) return varchar2;

    function enroll_new_acct (
        p_user_id in varchar2
    ) return varchar2;

    function get_email_from_taxid (
        p_tax_id in varchar2
    ) return varchar2;

    function get_products (
        p_user_id in number
    ) return accounts_t
        pipelined
        deterministic;

    function show_alert (
        p_user_id in varchar2
    ) return varchar2;

    function get_nav_list (
        p_user_id               in number,
        p_account_type          in varchar2,
        p_is_broker             in varchar2 default null,
        p_broker_enroll         in varchar2 default null,
        p_broker_renewal        in varchar2 default null,
        p_broker_invoices       in varchar2 default null,
        p_broker_enroll_ee      in varchar2 default null  --- ticket 7781 prabu on 17/05/2019
        ,
        p_broker_enroll_rpts    in varchar2 default null  --- ticket 7781 prabu on 17/05/2019
        ,
        p_broker_ee             in varchar2 default null    --- ticket 7781 prabu on 17/05/2019
        ,
        p_allow_bro_upd_pln_doc in varchar2 default null    --- ticket 8728  prabu on 18/02/2020
        ,
        p_tax_id                in varchar2 default null
    )/*Ticket#6834 */ return roles_t
        pipelined
        deterministic;

   --- rprabu 06/05/2020 #ticket 8837
    function get_nav_list_v2_old (
        p_user_id               in number,
        p_account_type          in varchar2,
        p_is_broker             in varchar2 default null,
        p_broker_enroll         in varchar2 default null,
        p_broker_renewal        in varchar2 default null,
        p_broker_invoices       in varchar2 default null,
        p_broker_enroll_ee      in varchar2 default null,
        p_broker_enroll_rpts    in varchar2 default null,
        p_broker_ee             in varchar2 default null,
        p_allow_bro_upd_pln_doc in varchar2 default null,
        p_tax_id                in varchar2 default null
    ) return pc_users.roles_t
        pipelined
        deterministic;

    function get_user_details (
        p_tax_id          in varchar2,
        p_conf_email_type in varchar2
    ) return user_det_t
        pipelined
        deterministic;

    function get_ee_enrolled_products (
        p_ssn in varchar2
    ) return accounts_t
        pipelined
        deterministic;

    function get_er_enrolled_products (
        p_ein in varchar2
    ) return accounts_t
        pipelined
        deterministic;

    function get_user_info_by_uname (
        p_user_name in varchar2
    ) return user_info_t
        pipelined
        deterministic;

    function get_er_not_enrolled_plans (
        p_ein in varchar2
    ) return accounts_t
        pipelined
        deterministic;

    function get_all_products (
        p_user_id in number
    ) return accounts_t
        pipelined
        deterministic;

    function chk_all_product_enroll (
        p_tax_id in varchar2
    ) return varchar2;
  /* Added this func to list products with enrollment complete for online portal*/
    function get_products_er_online (
        p_user_id in number
    ) return accounts_t
        pipelined
        deterministic;

    function skip_now_func (
        p_tax_id in varchar2
    ) return roles_t
        pipelined
        deterministic;

    function get_pwd_recovery (
        p_user_name in varchar2
    ) return user_info_t
        pipelined
        deterministic;

    procedure verify_pwd_recovery (
        p_user_id       in number,
        p_user_type     in varchar2,
        p_id_info       in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    g_dup_user_for_tax varchar2(3200) := 'A username and password already exists for this account.'
                                         || 'Remember that you can access all of your accounts with a single username and password. '
                                         || 'If you cannot remember your username or password, '
                                         || 'you may contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com.'
                                         ;
    g_no_tax_er varchar2(3200) := 'The tax ID you have provided is not associated with this account number. ' || 'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com. '
    ;
    g_no_tax_ee varchar2(3200) := 'The social security number you have provided is not associated with this account number. ' || 'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com.  '
    ;
    g_acct_closed_er varchar2(3200) := 'The Account has been closed. ' || 'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com. '
    ;
    g_invalid_ssn varchar2(3200) := 'The social security number associated with your account is not valid, ' || 'Please contact customer service at 800-617-4729 or email customer.service@sterlingadministration.com for assistance with correcting your social security number  '
    ;

    /*BroketSS0 Ticket#6834 */
    function get_broker_to_user_info (
        p_acc_num   in varchar2,
        p_user_id   in varchar2   --- 8837 12/05/2020
        ,
        p_broker_id in number,
        p_is_broker in varchar2
    ) return user_info_t
        pipelined
        deterministic;

    -- 9132 rprabu added to identify the broker is main or sub broker account
    function is_main_online_broker (
        p_user_id number
    ) return varchar2;

     -- Added by Jaggi #9771
    procedure update_login_info (
        p_user_id   number,
        p_ip_addess in varchar2
    );
     -- Added By Jaggi #9731
    function get_user_type (
        p_user_id in number
    ) return varchar2;
      -- Added by Jaggi #9804
    procedure sam_users_pwd_history (
        p_user_id  in number,
        p_password in varchar2
    );

    -- Added by Joshi #9902
    function get_nav_list_v2 (
        p_user_id      in number,
        p_account_type in varchar2,
        p_auth_req_id  in number,
        p_tax_id       in varchar2 default null
    ) return pc_users.roles_t
        pipelined
        deterministic;

    -- Added by Joshi #9902
    function enroll_new_acct_by_ein (
        p_tax_id in varchar2
    ) return varchar2;

-- Added by Jaggi #11368
    function get_ga_to_user_info (
        p_acc_num in varchar2,
        p_user_id in varchar2,
        p_ga_id   in number
    ) return user_info_t
        pipelined
        deterministic;

-- Added by Joshi for 12705
-- Added by Joshi for 12705
    function enable_employer_tab (
        p_auth_req_id in number,
        p_user_id     in number
    ) return varchar2;

end pc_users;
/


-- sqlcl_snapshot {"hash":"e72a459345b2261a7635839cf8604fbf5826c39b","type":"PACKAGE_SPEC","name":"PC_USERS","schemaName":"SAMQA","sxml":""}