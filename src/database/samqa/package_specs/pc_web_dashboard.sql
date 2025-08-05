create or replace package samqa.pc_web_dashboard as
    type rec_brkr is record (
            name     varchar2(255),
            ee_count number,
            prcnt    varchar2(30)
    );
    type rec_dash is record (
            acc_num             varchar2(20),
            product_type        varchar2(30),
            effective_date      varchar2(12),
            plan_year           varchar2(25),
            employee_count      varchar2(10),
            annual_election     number,
            available_balance   number,
            debit_card_bal      number,
            disbursement        number,
            plan_name           varchar2(35),
            plan_type           varchar2(30),
            single              varchar2(10),
            family              varchar2(10),
            show_account_online varchar2(1),    -- Added by Swamy for Ticket#9332 on 06/11/2020
            inactive_plan_flag  varchar2(1)     -- Added  by Joshi for Ticket#10430 on 04/11/2021
    );
    type ee_hsa_detail_rec is record (
            single_contrib_limit number,
            famly_contrib_limit  number,
            disbursement_ytd     number,
            receipt_ytd          number,
            catchup              number
    );
    type ee_hra_fsa_detail_rec is record (
            plan_name         varchar2(35),
            plan_year         varchar2(25),
            annual_election   number,
            disbursement_ytd  number,
            available_balance number
    );
    type rec_broker_person is record (
            name                         varchar2(255),
            acc_num                      varchar2(15),
            acc_id                       number,             -- Added by Joshi for 9902
            contribution                 varchar2(30),
            disbursement                 varchar2(30),
            status                       varchar2(100),  /*Ticket#6834.Increase length to displa pending Activation */
            effective_end_date           date,
            balance                      varchar2(30),
            no_ee                        number,
            account_type                 varchar2(30),
            sso_enabled                  varchar2(1),
            tax_id                       varchar2(20),
            show_renewal_link            varchar2(2),/*Ticket#6834 */
            show_enroll_link             varchar2(2),
            account_description          varchar2(40),    -- Added by Swamy for Ticket#9384
            renewal_deadline             date,            -- Added by Swamy for Ticket#9384
            broker_request_status        varchar2(1),   -- Added by Joshi for 9902
            authorize_req_id             number             -- Added by Joshi for 9902
            ,
            renewal_resubmit_assigned_to varchar2(10)-- Added by swamy for Ticket#11636
            ,
            renewal_resubmit_flag        varchar2(10),-- Added by swamy for Ticket#11636
            contact_team_url             varchar2(500),   -- Added by Jaggi
            contact_phone_num            varchar2(30),    -- Added by Jaggi
            contact_email                varchar2(100),   -- Added by Jaggi
            contact_name                 varchar2(100)    -- Added by Jaggi
    );
    type rec_brkr_count is record (
            name     varchar2(255),
            ee_count varchar2(5),
            prcnt    varchar2(5)
    );
    type rec_graph is record (
            mnth_yr varchar2(10),
            amount  number
    );
    type rec_claim is record (
            status                 varchar2(30),
            claim_amount           number,
            paid_dt                varchar2(10),
            unsubstantiated_amount number,
            claim_source           varchar2(30)
    );
    type tbl_rec_dash is
        table of rec_dash;
    type tbl_brkr is
        table of rec_brkr;
    type tbl_graph is
        table of rec_graph;
    type ee_hsa_detail_tbl is
        table of ee_hsa_detail_rec;
    type ee_hra_fsa_detail_tbl is
        table of ee_hra_fsa_detail_rec;
    type tbl_broker_person is
        table of rec_broker_person;
    type tbl_brkr_count is
        table of rec_brkr_count;
    type tbl_claim is
        table of rec_claim;
    function get_broker_info (
        p_brokr_id in varchar2
    ) return tbl_brkr
        pipelined
        deterministic;

    function get_broker_enterprise (
        p_broker_id    number,
        p_account_type varchar2 default null,
        p_tax          varchar2 default null,
        p_client_name  in varchar2 default null  -- Added by Swamy for Ticket#12129 02/05/2024
    ) return tbl_broker_person
        pipelined;

    function get_broker_person (
        p_broker_id    number,
        p_account_type varchar2 default null,
        p_tax          varchar2 default null
    ) return tbl_broker_person
        pipelined;

    function get_employer_info (
        p_entrp_id   in number,
        p_entrp_code in varchar2
    ) return tbl_rec_dash
        pipelined
        deterministic;

    function get_employee_info (
        p_acc_id in number,
        p_ssn    in varchar2
    ) return tbl_rec_dash
        pipelined
        deterministic;

    function f_employer_hsa_contribution (
        p_entrp_id in number
    ) return tbl_graph
        pipelined
        deterministic;

    function f_employer_hsa_distribution (
        p_entrp_id in number
    ) return tbl_graph
        pipelined
        deterministic;

    function f_er_fsa_hra_claim (
        p_entrp_id  in number,
        p_plan_type in varchar2
    ) return tbl_graph
        pipelined
        deterministic;

    function f_er_fsa_hra_funding (
        p_entrp_id  in number,
        p_plan_type in varchar2
    ) return tbl_graph
        pipelined
        deterministic;

    function f_ee_hsa_detail (
        p_acc_id in number
    ) return ee_hsa_detail_tbl
        pipelined
        deterministic;

    function f_ee_hra_fsa_detail (
        p_acc_id in number
    ) return ee_hra_fsa_detail_tbl
        pipelined
        deterministic;

    function f_employee_hsa_distribution (
        p_acc_id in number
    ) return tbl_graph
        pipelined
        deterministic;

-- Added by Jaggi #11368
    type rec_ga_person is record (
            name                         varchar2(255),
            acc_id                       number,
            acc_num                      varchar2(15),
            entrp_code                   varchar2(20),
            status                       varchar2(100),
            account_type                 varchar2(30),
            show_renewal_link            varchar2(2),
            renewal_deadline             varchar2(30),
            authorize_req_id             number         -- Added by swamy for Ticket#11368(broker)
            ,
            signature_account_status     number  -- Added by swamy for Ticket#11368(broker)
            ,
            renewal_resubmit_assigned_to varchar2(10)  -- Added by swamy for Ticket#11636
            ,
            renewal_resubmit_flag        varchar2(10)  -- Added by swamy for Ticket#11636
            ,
            disable_resubmit_flag        varchar2(10)  -- Added by swamy for Ticket#11636
    );
    type tbl_ga_person is
        table of rec_ga_person;
    function get_ga_enterprise (
        p_ga_id        number,
        p_broker_id    in number,
        p_account_type varchar2 default null
    ) return tbl_ga_person
        pipelined;

end;
/


-- sqlcl_snapshot {"hash":"d280bfe35c328e3896ba8e981a1822675a25b467","type":"PACKAGE_SPEC","name":"PC_WEB_DASHBOARD","schemaName":"SAMQA","sxml":""}