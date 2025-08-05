create or replace package samqa.pc_crm_interface as
    type crm_interface_rec is record (
            acc_num            varchar2(30),
            address            varchar2(255),
            city               varchar2(100),
            state              varchar2(100),
            zip                varchar2(100),
            salesrep_id        varchar2(30),
            am_id              varchar2(100),
            broker_id          varchar2(30),
            account_status     varchar2(30),
            end_date           varchar2(30),
            broker_name        varchar2(255),
            broker_lic         varchar2(255),
            crm_id             varchar2(255),
            change_source      varchar2(255),
            date_modified      varchar2(30),
            at_risk_of         varchar2(1)    --code added by preethy for ticket no:6071.
            ,
            reference_flag     varchar2(1),
            termination_reason varchar2(4000)
    );
    type crm_interface_t is
        table of crm_interface_rec;
    type renewal_rec is record (
            employer_name         varchar2(255),
            acc_num               varchar2(30),
            account_type          varchar2(30),
            broker_name           varchar2(255),
            broker_id             number,
            salesrep_id           number,
            ga_id                 number,
            ga_name               varchar2(255),
            css_id                number,
            funding_options       varchar2(255),
            funding_option_amount number,
            ga                    varchar2(255),
            entrp_id              number,
            start_date            varchar2(30),
            end_date              varchar2(30),
            eligible_ee           number,
            renewal_amount        number,
            optional_fee          number,
            total_fee             number,
            note                  varchar2(2000),
            payment_method        varchar2(30),
            broker_contact        varchar2(255),
            ga_contact            varchar2(255),
            invoice_to            varchar2(100),
            date_closed           varchar2(30),
            ben_plan_id           number,
            ein                   varchar2(30),
            acc_id                number,
            account_manager       number,
            assigned_user         varchar2(100),
            ben_plan_number       varchar2(30) -- added by Joshi for 7661.
    );
    type renewal_row_t is
        table of renewal_rec;
    procedure process_interface_status (
        p_entity_name      in varchar2,
        p_entity_id        in varchar2,
        p_interface_id     in varchar2,
        p_interface_status in varchar2
    );

    procedure email_crm_imported_accounts;

    function get_opportunity (
        p_account_type in varchar2
    ) return renewal_row_t
        pipelined
        deterministic;

    function get_renewal_opportunity (
        p_account_type in varchar2
    ) return renewal_row_t
        pipelined
        deterministic;

    procedure export_changes_report (
        p_acc_id    in number,
        p_file_name in varchar2
    );

    function get_account_changes_for_crm return crm_interface_t
        pipelined
        deterministic;

    function get_er_account_changes_for_crm return crm_interface_t
        pipelined
        deterministic;

end pc_crm_interface;
/


-- sqlcl_snapshot {"hash":"cf3181f53d43ad51b75d796d5d873de4ce1f0f96","type":"PACKAGE_SPEC","name":"PC_CRM_INTERFACE","schemaName":"SAMQA","sxml":""}