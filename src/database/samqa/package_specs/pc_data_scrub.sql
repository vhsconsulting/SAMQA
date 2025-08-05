create or replace package samqa.pc_data_scrub as

  /* TODO enter package declarations (types, exceptions, methods etc) here */
    procedure process_ssn (
        p_entrp_id in varchar2
    );

    procedure process_bank_acct;

    procedure process_routing_num;

    procedure run (
        p_entrp_id in varchar2
    );

    procedure purge_tables;

    procedure process_enterprise;

end pc_data_scrub;
/


-- sqlcl_snapshot {"hash":"ed527d60a0424af83fd8a546746bca8abf4df0a6","type":"PACKAGE_SPEC","name":"PC_DATA_SCRUB","schemaName":"SAMQA","sxml":""}