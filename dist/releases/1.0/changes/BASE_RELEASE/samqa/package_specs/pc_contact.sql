-- liquibase formatted sql
-- changeset SAMQA:1754374135380 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_contact.sql:null:5f9bc0f963e348973df2527f5c78f8a8f38ffa0e:create

create or replace package samqa.pc_contact as
    type contact_info_row_t is record (
            first_name      varchar2(255),
            last_name       varchar2(255),
            middle_name     varchar2(255),
            contact_name    varchar2(2000),
            title           varchar2(255),
            effective_date  varchar2(255),
            role_permission varchar2(255),
            contact_id      number,
            user_id         number,
            role_id         varchar2(255),
            email           varchar2(4000),
            fax             varchar2(255),
            phone           varchar2(255),
            entity_type     varchar2(255),
            contact_type    varchar2(255)  --rprabu 08/06/2021  CP project
            ,
            account_type    varchar2(30)    -- added by Jaggi #10742
            ,
            entity_id       varchar2(255),
            user_name       varchar2(255),
            status          varchar2(255),
            pw_setup        varchar2(255),
            name            varchar2(255),
            user_type       varchar2(255)
    );  -- Added by Joshi for 9527

    type contact_info_t is
        table of contact_info_row_t;
    procedure create_contact (
        p_first_name    in varchar2,
        p_last_name     in varchar2,
        p_middle_name   in varchar2,
        p_title         in varchar2,
        p_gender        in varchar2,
        p_entity_id     in varchar2,
        p_phone         in varchar2,
        p_fax           in varchar2,
        p_email         in varchar2,
        p_user_id       in number,
        x_contact_id    out number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure delete_user_contact (
        p_contact_user_id in number,
        p_contact_id      in number,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure update_user_contact (
        p_contact_id      in number,
        p_first_name      in varchar2,
        p_last_name       in varchar2,
        p_middle_name     in varchar2,
        p_title           in varchar2,
        p_entity_id       in varchar2,
        p_ein             in varchar2,
        p_phone           in varchar2,
        p_fax             in varchar2,
        p_email           in varchar2,
        p_role_id         in varchar2,
        p_role_entries    in pc_online_enrollment.varchar2_tbl,
        p_contact_user_id in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure create_user_contact (
        p_first_name         in varchar2,
        p_last_name          in varchar2,
        p_middle_name        in varchar2,
        p_title              in varchar2,
        p_gender             in varchar2,
        p_entity_id          in varchar2,
        p_ein                in varchar2,
        p_phone              in varchar2,
        p_fax                in varchar2,
        p_email              in varchar2,
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_id            in number,
        p_role_id            in number,
        p_first_time_pw_flag in varchar2 default 'N',
        p_role_entries       in pc_online_enrollment.varchar2_tbl,
        x_contact_id         out number,
        x_user_id            out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );
	----8837 rprabu 07/05/2020
    procedure create_broker_user_contact (
        p_first_name         in varchar2,
        p_last_name          in varchar2,
        p_middle_name        in varchar2,
        p_title              in varchar2,
        p_gender             in varchar2
     ----   ,p_entity_id    IN VARCHAR2   8837 prabu 08/05/2020
        ,
        p_ein                in varchar2,
        p_phone              in varchar2,
        p_fax                in varchar2,
        p_email              in varchar2,
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_id            in number,
        p_role_id            in number,
        p_first_time_pw_flag in varchar2 default 'N',
        p_role_entries       in pc_online_enrollment.varchar2_tbl,
        x_contact_id         out number,
        x_user_id            out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    function get_user_contact_info (
        p_tax_id in varchar2
    ) return contact_info_t
        pipelined
        deterministic;

    function get_user_contact_profile (
        p_user_id in varchar2
    ) return contact_info_t
        pipelined
        deterministic;

    function get_contact_id_for_cobra (
        p_cobra_number in number
    ) return number;

    function get_contact_roles (
        p_contact_id in number
    ) return varchar2;

    function get_notify_emails (
        p_ein          in varchar2,
        p_notify_type  in varchar2,
        p_product_type in varchar2,
        p_inv_id       in number default null
    ) return contact_info_t
        pipelined
        deterministic;

    function get_contact_name (
        p_ein          in varchar2,
        p_notify_type  in varchar2,
        p_product_type in varchar2
    ) return contact_info_t
        pipelined
        deterministic;

    function get_contact_info (
        p_ein          varchar2,
        p_contact_type in varchar2 default null
    ) return contact_info_t
        pipelined;

    function get_salesrep_email (
        p_entrp_id in number
    ) return varchar2;

    function get_super_admin_email (
        p_tax_id in varchar2
    ) return varchar2;
        -- added for PPP.
    function get_primary_email (
        p_ein          in varchar2,
        p_account_type in varchar2,
        p_entity_type  in varchar2 default 'ENTERPRISE'   -- Added by Swamy for Ticket#11087
    ) return contact_info_t
        pipelined
        deterministic;

    procedure get_names (
        p_entrp_code     in varchar2,
        p_entrp_contact  in varchar2,
        p_first_name     out varchar2,
        p_last_name      out varchar2,
        p_gender         out varchar2,
        x_process_status out varchar2,
        x_error_message  out varchar2
    );

    ----9527  rprabu 05/11/2020
    procedure create_br_ga_user_contact (
        p_first_name         in varchar2,
        p_last_name          in varchar2,
        p_middle_name        in varchar2,
        p_title              in varchar2,
        p_gender             in varchar2,
        p_ein                in varchar2,
        p_phone              in varchar2,
        p_fax                in varchar2,
        p_email              in varchar2,
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_id            in number,
        p_role_id            in number,
        p_first_time_pw_flag in varchar2 default 'N',
        p_role_entries       in pc_online_enrollment.varchar2_tbl,
        p_entity_type        in varchar2           ------9527   05/11/2020
        ,
        x_contact_id         out number,
        x_user_id            out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

-- Added by Joshi for 9527
    function get_user_info (
        p_user_id number
    ) return contact_info_t
        pipelined;

-- Added by Jaggi #11699                          
    function get_notify_all_contacts (
        p_ein          in varchar2,
        p_notify_type  in varchar2,
        p_product_type in varchar2,
        p_inv_id       in number default null
    ) return contact_info_t
        pipelined
        deterministic;

-- Added by Joshi for 12396 Sprint 57: GIACT Reminder email
    function get_broker_super_admin_email (
        p_broker_lic in varchar2
    ) return varchar2;

    function get_ga_super_admin_email (
        p_ga_lic in varchar2
    ) return varchar2;

end pc_contact;
/

