-- liquibase formatted sql
-- changeset SAMQA:1754374134501 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_broker.sql:null:f2175bc238b4be68b2c6d67ab6ae58690d9d108e:create

create or replace package samqa.pc_broker is

  /*
  ??????????:
     ??? ???????????? ??????? ????????
  ?????????:
     25.07.2004 - SeF - ????????
  */
    type varchar2_tbl is
        table of varchar2(300) index by binary_integer;
    type broker_row is record (
            broker_id    number,
            broker_lic   varchar2(255),
            broker_name  varchar2(255),
            last_name    varchar2(255),
            first_name   varchar2(255),
            address      varchar2(255),
            city         varchar2(255),
            state        varchar2(30),
            zip          varchar2(30),
            broker_phone varchar2(30),
            broker_email varchar2(100),
            broker_rate  number,
            broker_comm  varchar2(30),
            start_date   varchar2(30),
            agency_name  varchar2(255),
            ga_id        number,
            flg_agree    varchar2(1)  -- Added by swamy for Ticket#7660

    );
    type broker_t is
        table of broker_row;
    type broker_prod_row is record (
            product_type    varchar2(255),
            plan_type       varchar2(255),
            account_meaning varchar2(255)
    );
    type broker_prod_t is
        table of broker_prod_row;
    type rec_ga_lic is record (
            ga_id       number,
            agency_name varchar2(100),
            ga_lic      varchar2(20),
            email       varchar2(100)
    );
    type tbl_ga_lic is
        table of rec_ga_lic;
    type broker_authorize_info_row is record (
            acc_id           number,
            account_type     varchar2(30),
            acc_num          varchar2(20),
            employer_name    varchar2(255),
            authorize_option varchar2(255),
            descriptions     varchar2(255),
            is_authorized    varchar2(1),
            nav_code         varchar2(255),
            broker_id        number,
            broker_name      varchar2(255),
            authorize_req_id number,
            request_status   varchar2(255)
    );
    type broker_authorize_info_t is
        table of broker_authorize_info_row;
    type broker_permission_row is record (
            authorize_option varchar2(255),
            is_authorized    varchar2(1),
            nav_code         varchar2(255),
            authorize_req_id number
    );
    type broker_permission_row_t is
        table of broker_permission_row;

  -- ????????? ???????? ????? ?????? ? ??????? (PERSON, BROKER)
    procedure cre_broker (
        first_name_in             in person.first_name%type,
        last_name_in              in person.last_name%type,
        address_mail_in1          in person.address%type                          --- Modified by rprabu on 07/02/2018
        ,
        address_mail_in2          in person.address%type                          --- Added by rprabu on 07/02/2018
        ,
        city_in                   in person.city%type,
        state_in                  in person.state%type,
        zip_in                    in person.zip%type,
        commissions_payable_to_in in broker.commissions_payable_to%type     --- Added by rprabu on 07/02/2018
        ,
        phy_address_flag_in       in person.phy_address_flag%type       	   --- Added by rprabu on 07/02/2018
        ,
        address_phy_in1           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        address_phy_in2           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        city_in1                  in person.city%type   			                       --- Added by rprabu on 07/02/2018
        ,
        state_in1                 in person.state%type                                    --- Added by rprabu on 07/02/2018
        ,
        zip_in1                   in person.zip%type                                        --- Added by rprabu on 07/02/2018
        ,
        phone_day_in              in person.phone_day%type,
        phone_evening_in          in person.phone_day%type                         --- Added by rprabu on /02/2018
        ,
        email_in                  in person.email%type,
        ssn_in                    in person.ssn%type,
        start_date_in             in broker.start_date%type,
        end_date_in               in broker.end_date%type,
        broker_lic_in             in broker.broker_lic%type,
        broker_rate_in            in broker.broker_rate%type,
        share_rate_in             in broker.share_rate%type,
        ga_rate_in                in broker.ga_rate%type,
        ga_id_in                  in broker.ga_id%type,
        note_in                   in broker.note%type,
        agency_name_in            in broker.agency_name%type,
        salesrep_id_in            in broker.salesrep_id%type,
        user_id_in                in number                             --- Added by rprabu on  12/02/2018
        ,
        cheque_flag_in            in varchar2 default null                           --- Added by rprabu on  24/06/2019 for 7901
        ,
        reason_flag_in            in varchar2 default null                            --- Added by rprabu on  24/06/2019 for 7901
        ,
        p_am_id                   in number default null           --- Added by swamy on  01/07/2024 for 12247
        ,
        broker_id_out             out broker.broker_id%type
    );
  -- ????????? ?????????? ?????? ? ??????? (PERSON, BROKER)
    procedure upd_broker (
        broker_id_in              in broker.broker_id%type,
        first_name_in             in person.first_name%type,
        last_name_in              in person.last_name%type,
        address_mail_in1          in person.address%type                          --- Modified by rprabu on 07/02/2018
        ,
        address_mail_in2          in person.address%type                           --- Added by rprabu on 07/02/2018
        ,
        city_in                   in person.city%type,
        state_in                  in person.state%type,
        zip_in                    in person.zip%type,
        commissions_payable_to_in in broker.commissions_payable_to%type     --- Added by rprabu on 07/02/2018
        ,
        phy_address_flag_in       in person.phy_address_flag%type                --- Added by rprabu on 07/02/2018
        ,
        address_phy_in1           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        address_phy_in2           in person.address%type                            --- Added by rprabu on 07/02/2018
        ,
        city_in1                  in person.city%type   			                       --- Added by rprabu on 07/02/2018
        ,
        state_in1                 in person.state%type                    				   --- Added by rprabu on 07/02/2018
        ,
        zip_in1                   in person.zip%type                    					   --- Added by rprabu on 07/02/2018
        ,
        phone_day_in              in person.phone_day%type,
        email_in                  in person.email%type,
        ssn_in                    in person.ssn%type,
        start_date_in             in broker.start_date%type,
        end_date_in               in broker.end_date%type,
        broker_lic_in             in broker.broker_lic%type,
        broker_rate_in            in broker.broker_rate%type,
        share_rate_in             in broker.share_rate%type,
        ga_rate_in                in broker.ga_rate%type,
        ga_id_in                  in broker.ga_id%type,
        note_in                   in broker.note%type,
        agency_name_in            in broker.agency_name%type,
        salesrep_id_in            in broker.salesrep_id%type,
        verified_by_in            in broker.verified_by%type        --- Added by rprabu on  14/03/2018
        ,
        verified_date_in          in broker.verified_date%type      --- Added by rprabu on  14/03/2018
        ,
        user_id_in                in number                             --- Added by rprabu on  12/02/2018
        ,
        cheque_flag_in            in varchar2 default null                        --- Added by rprabu on  24/06/2019 for 7901
        ,
        reason_flag_in            in varchar2 default null                        --- Added by rprabu on  24/06/2019 for 7901
        ,
        p_am_id                   in number default null           --- Added by swamy on  01/07/2024 for 12247
    );
  -- ????????? ???????? ?????? ? ??????? (PERSON, BROKER)
    procedure del_broker (
        broker_id_in in broker.broker_id%type
    );

    procedure upd_broker_online (
        broker_id_in    in broker.broker_id%type,
        first_name_in   in person.first_name%type,
        last_name_in    in person.last_name%type,
        address_in      in person.address%type,
        city_in         in person.city%type,
        state_in        in person.state%type,
        zip_in          in person.zip%type,
        phone_day_in    in person.phone_day%type,
        email_in        in person.email%type,
        broker_lic_in   in broker.broker_lic%type,
        agency_name_in  in broker.agency_name%type,
        user_name_in    in varchar2,
        p_user_id       in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure validate_broker_assign (
        p_broker_assignment_id in number,
        p_broker_id            in number,
        p_entrp_id             in number,
        p_pers_id              in number,
        p_effective_date       in varchar2,
        p_effective_end_date   in varchar2,
        p_user_id              in number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    procedure insert_broker_assign (
        p_broker_assignment_id in number,
        p_broker_id            in number,
        p_entrp_id             in number,
        p_pers_id              in number,
        p_effective_date       in varchar2,
        p_salesrep_id          in varchar2,
        p_user_id              in number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    procedure update_broker_assign (
        p_broker_assignment_id in number,
        p_broker_id            in number,
        p_entrp_id             in number,
        p_pers_id              in number,
        p_effective_date       in varchar2,
        p_effective_end_date   in varchar2,
        p_salesrep_id          in varchar2,
        p_user_id              in number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    function get_broker_name (
        p_broker_id in number
    ) return varchar2;

    function get_broker_lic (
        p_broker_id in number
    ) return varchar2;

    function get_salesrep_id (
        p_broker_id in number
    ) return number;

    function get_effective_date (
        p_pers_id   in number,
        p_broker_id in number
    ) return varchar2;

    function get_er_count (
        p_broker_id    in number,
        p_account_type in varchar2 default 'HSA'
    ) return number;

    function get_pers_count (
        p_broker_id    in number,
        p_acc_status   in number,
        p_account_type in varchar2 default 'HSA'
    ) return number;

    function get_broker_info (
        p_broker_lic in varchar2
    ) return broker_t
        pipelined
        deterministic;

    function get_broker_info (
        p_broker_id in number
    ) return broker_t
        pipelined
        deterministic;

    function get_broker_prod (
        p_broker_id in number
    ) return broker_prod_t
        pipelined
        deterministic;

    function get_broker_info_from_acc_id (
        p_acc_id number
    ) return broker_t
        pipelined;

    function get_ga_info (
        p_entrp_id number
    ) return tbl_ga_lic
        pipelined;

    procedure insert_sales_team_leads (
        p_first_name      varchar2,
        p_last_name       varchar2,
        p_license         varchar2,
        p_agency_name     varchar2,
        p_tax_id          varchar2,
        p_gender          varchar2,
        p_address         varchar2,
        p_city            varchar2,
        p_state           varchar2,
        p_zip             varchar2,
        p_phone1          varchar2,
        p_phone2          varchar2,
        p_email           varchar2,
        p_entrp_id        number,
        p_ref_entity_id   number,
        p_ref_entity_type varchar2,
        p_lead_source     varchar2,
        p_entity_type     varchar2
    );

-- Added by swamy for Ticket#7660
-- Procedure to update the flg_agree column of the broker.
-- After broker creation, for the first time broker login, user will be prompted with a message to agree/Disagree
-- an agreement in electronic format. This update is done in the below procedure. This message will appear only for the first time Broker Login.

    procedure upd_broker_flg_agree (
        p_broker_id in number,
        p_flg_agree in varchar2
    );

-- For SQL Injection Start added by Swamy
    type emp_info_row_t is record (
            name              varchar2(306),
            acc_num           varchar2(20),
            start_date        varchar2(50),
            end_date          varchar2(50),
            annual_election   number,
            acc_balance       number,
            benefit_year      varchar2(21),
            plan_type_meaning varchar2(4000),
            first_name        varchar2(200),
            last_name         varchar2(200),
            row_num           number,
            rn                number
    );
    type emp_info_t is
        table of emp_info_row_t;
    function getemployeeinfo (
        p_entrp_id    in number,
        p_plan_type   in varchar2,
        p_first_name  in varchar2,
        p_last_name   in varchar2,
        p_acc_num     in varchar2,
        p_start_date  in varchar2,
        p_end_date    in varchar2,
        p_sort_column in varchar2,
        p_sort_order  in varchar2,
        p_start_row   in varchar2,     -- Swamy #12013 12022024
        p_end_row     in varchar2      -- Swamy #12013 12022024
    ) return emp_info_t
        pipelined
        deterministic;

    type l_cursor is ref cursor;






  -- Added by rprabu 21/06/2019 for ticket#7901
    function check_broker_doc (
        p_broker_id number,
        p_doc_type  varchar2
    ) return varchar2;

   -- Broker_Pedning CLient Info ##9617 added by Jaggi 13/01/2021
    type get_broker_pending_info_row_t is record (
            client_name        varchar2(500),
            ein                varchar2(100),
            user_id            number,
            email              varchar2(100),
            account_number     varchar2(100),
            acct_type          varchar2(100),
            account_type_desc  varchar2(300),
            account_status     varchar2(10),
            status             varchar2(200),
            broker_name        varchar2(300)   -- Added by Jaggi ##9603
            ,
            general_agent_name varchar2(300),
            general_agent_id   number,
            phone_number       varchar2(100),
            complete_flag      varchar2(1),
            industry_type      varchar2(2000),
            resubmit_flag      varchar2(1)
    );  -- added by jaggi #10431)
    type get_broker_pending_info_t is
        table of get_broker_pending_info_row_t;
    function get_broker_pending_info (
        p_broker_id   in number,
        p_client_name varchar2,
        p_acct_type   varchar2,
        p_acct_status varchar2
    ) return get_broker_pending_info_t
        pipelined
        deterministic;
    -- added by Jaggi for #9902
    procedure insert_broker_auth_req (
        p_broker_id        in number,
        p_acc_id           in number,
        p_broker_user_id   in number,
        p_user_id          in number,
        x_authorize_req_id out number,
        x_error_status     out varchar2,
        x_error_message    out varchar
    );
    -- Added by Joshi for #9902
    function get_broker_authorise_info (
        p_tax_id in varchar2
    ) return broker_authorize_info_t
        pipelined
        deterministic;

    function get_broker_authorize_req_info (
        p_broker_id in number,
        p_acc_id    in number
    ) return varchar2;

    function get_broker_authorize_req_id (
        p_broker_id in number,
        p_acc_id    in number
    ) return number;
    -- Added by Jaggi for #9902
    function show_broker_authorize_notify (
        p_ein varchar2
    ) return varchar2;
    -- Added by Jaggi for 9902
    procedure update_broker_auth (
        p_acc_id           number,
        p_broker_id        number,
        p_authorize_req_id number,
        p_authorize_option pc_online_enrollment.varchar2_tbl,
        p_is_authorized    pc_online_enrollment.varchar2_tbl,
        p_nav_code         pc_online_enrollment.varchar2_tbl,
        p_user_id          in number,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    );
   -- Added by Jaggi for 9902
    procedure create_broker_authorize (
        p_broker_id        in number,
        p_acc_id           in number,
        p_broker_user_id   in number,
        p_authorize_req_id number,
        p_user_id          in number,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    );
  -- Added by Jaggi for 9902
    procedure remove_broker_authorize (
        p_broker_id in number,
        p_acc_id    in number
    );

  -- Added by Swamy for Ticket#10747
    procedure get_broker_id (
        p_user_id     in number,
        p_entity_type out varchar2,
        p_broker_id   out number
    );

  -- Added by Swamy for Ticket#11087
    type broker_serv_doc_row is record (
            attachment_id    number,
            document_name    varchar2(3200),
            description      varchar2(1000),
            creation_date    date,
            document_purpose varchar2(100),
            employer_name    varchar2(100)
    );
    type broker_serv_doc_t is
        table of broker_serv_doc_row;

  -- Added by Swamy for Ticket#11087
    function get_broker_service_documents (
        p_broker_id in number
    ) return broker_serv_doc_t
        pipelined
        deterministic;

  -- Added by Jaggy 
    type broker_salesrep_details_row is record (
            salesrep_name      varchar2(3200),
            salesrep_email     varchar2(1000),
            salesrep_phone_num varchar2(200),
            salesrep_team_url  varchar2(32000)
    );
    type broker_salesrep_details_t is
        table of broker_salesrep_details_row;
    function get_broker_salesrep (
        p_broker_id in number
    ) return broker_salesrep_details_t
        pipelined
        deterministic;

  -- Added by Jaggy 
    type broker_account_manager_row is record (
            account_manager_name  varchar2(3200),
            account_manager_email varchar2(1000),
            account_manager_phone varchar2(200),
            account_manager_url   varchar2(32000)
    );
    type broker_account_manager_details_t is
        table of broker_account_manager_row;
    function get_broker_account_manager (
        p_broker_id in number
    ) return broker_account_manager_details_t
        pipelined
        deterministic;

end pc_broker;
/

