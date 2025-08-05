-- liquibase formatted sql
-- changeset SAMQA:1754374140387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_sales_team.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_sales_team.sql:null:9849e238d75d4e55fe1cd0fa88da3f6327907fea:create

create or replace package samqa.pc_sales_team is
    procedure cre_sales_team_member (
        entity_type_in           in sales_team_member.entity_type%type,
        entity_id_in             in sales_team_member.entity_id%type,
        mem_role_in              in sales_team_member.mem_role%type,
        emplr_id_in              in sales_team_member.emplr_id%type,
        start_date_in            in sales_team_member.start_date%type,
        end_date_in              in sales_team_member.end_date%type,
        status_in                in sales_team_member.status%type,
        creation_date_in         in sales_team_member.creation_date%type,
        created_by_in            in sales_team_member.created_by%type,
        last_update_date_in      in sales_team_member.last_update_date%type,
        last_updated_by_in       in sales_team_member.last_updated_by%type,
        pay_commission_in        in sales_team_member.pay_commission%type,
        notes_in                 in sales_team_member.notes%type,
        no_of_days_in            in sales_team_member.no_of_days%type,
        sales_team_member_id_out out sales_team_member.sales_team_member_id%type
    );

    procedure updt_sales_team_member (
        sales_team_member_id_in in sales_team_member.sales_team_member_id%type,
        entity_type_in          in sales_team_member.entity_type%type,
        entity_id_in            in sales_team_member.entity_id%type,
        mem_role_in             in sales_team_member.mem_role%type,
        emplr_id_in             in sales_team_member.emplr_id%type,
        start_date_in           in sales_team_member.start_date%type,
        end_date_in             in sales_team_member.end_date%type,
        status_in               in sales_team_member.status%type,
        last_update_date_in     in sales_team_member.last_update_date%type,
        last_updated_by_in      in sales_team_member.last_updated_by%type,
        pay_commission_in       in sales_team_member.pay_commission%type,
        notes_in                in sales_team_member.notes%type,
        no_of_days_in           in sales_team_member.no_of_days%type
    );

    procedure insert_broker_data (
        p_broker_id      in number,
        p_entrp_id       in number,
        p_pers_id        in number,
        p_effective_date in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure validate_broker_data (
        p_broker_id          in number,
        p_entrp_id           in number,
        p_effective_date     in varchar2,
        p_effective_end_date in varchar2,
        p_user_id            in number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    function get_general_agent_name (
        p_ga_id in number
    ) return varchar2;

    function get_sales_rep_name (
        p_salesrep_id in number
    ) return varchar2;

    function get_sales_rep_role (
        p_salesrep_id in number
    ) return varchar2; -- Added By Joshi for 5022.
    function validate_secondary (
        p_entity_id in number,
        p_emplr_id  in number
    ) return varchar2;

    function get_cust_srvc_rep_name (
        p_custrep_id in number
    ) return varchar2;

    function get_cust_srvc_rep_name_for_er (
        p_entrp_id in number
    ) return varchar2;

---------------------------rprabu 12/09/2023 
    function get_cust_srvc_rep_email_for_er (
        p_entrp_id in number
    ) return varchar2;

---------------------------rprabu 21/09/2023 
    function get_broker_email_for_er (
        p_entrp_id in number
    ) return varchar2;

---------------------------rprabu 21/09/2023 
    function get_carrier_email_for_er (
        p_entrp_id in number
    ) return varchar2;

---------------------------rprabu 21/09/2023 
    function get_contact_email_for_er (
        p_entrp_id in number
    ) return varchar2;

    procedure assign_sales_team (
        p_entrp_id    in number,
        p_entity_type in varchar2,
        p_entity_id   in number,
        p_eff_date    in date,
        p_user_id     in number
    );

    procedure upsert_sales_team_member (
        p_entity_type           in varchar2,
        p_entity_id             in number,
        p_mem_role              in varchar2,
        p_entrp_id              in number,
        p_start_date            in date,
        p_end_date              in date,
        p_status                in varchar2,
        p_user_id               in number,
        p_pay_commission        in varchar2,
        p_note                  in varchar2,
        p_no_of_days            in number,
        px_sales_team_member_id in out number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    );

    procedure assign_to_house_account;

    function get_sales_rep_id (
        p_salesrep_name in varchar2
    ) return number;

    procedure export_salesrep_data (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );
   /* Added for ticket#5022 */
    function get_salesrep_detail (
        p_entrp_id in number,
        p_mem_role in varchar2
    ) return number;


  /*Ticket#5422 */
    function get_salesrep_email (
        p_salesrep_id in number
    ) return varchar2;

  -- Procedure Added by Swamy on 11/07/2018 wrt Ticket#6074(Sales Team member for Subscriber)
  -- Update The Salesrep And Account Manager Details For The Subscriber.
    procedure update_account_subcriber (
        p_acc_id        in number,
        p_acc_num       in varchar2,
        p_salesrep_id   in number,
        p_mem_role      in varchar2,
        p_batch_number  in number,
        p_salesrep_name in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_sales_rep_id (
        p_entrp_id       in number,
        p_effective_date date,
        p_mem_role       in varchar2
    ) return number;

--- FOR COBRA Projects rprabu 30/06/2022
    function get_entity_id_er (
        p_entrp_id    in number,
        p_entity_name in varchar2
    ) return number;  --- get entity id for employer rprabu 19/09/2021

--Added by Jaggi
    function get_cust_srvc_rep_phone_num_for_er (
        p_entrp_id in number
    ) return varchar2;
--Added by Jaggi
    function get_cust_srvc_rep_url_for_er (
        p_entrp_id in number
    ) return varchar2;

end pc_sales_team;
/

