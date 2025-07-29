create or replace package samqa.claim_edi as
    type claim_edi_header_type is
        table of claim_edi_header%rowtype index by binary_integer; -- claim header
    type claim_edi_detail_type is
        table of claim_edi_detail%rowtype index by binary_integer; -- claim detail
    type claim_edi_service_detail_type is
        table of claim_edi_service_detail%rowtype index by binary_integer; -- claim serive detail

-- Vanitha: 04/04/2011
    type claim_detail_row_t is record (
            subscriber_name     varchar2(255),
            subscriber_number   varchar2(255),
            subscriber_address1 varchar2(255),
            subscriber_address2 varchar2(255),
            subscriber_city     varchar2(255),
            subscriber_state    varchar2(255),
            subscriber_zip      varchar2(255),
            subscriber_country  varchar2(255),
            patient_first_name  varchar2(255),
            patient_last_name   varchar2(255),
            patient_middle_name varchar2(255),
            patient_number      varchar2(255),
            claim_number        varchar2(255),
            claim_amount        varchar2(255),
            amount_to_be_paid   varchar2(255),
            claim_note          varchar2(255),
            eoq_reqd            varchar2(255),-- added this 04/07/2011
            pers_id             number(9, 0), -- GN added this 04/08/2011
            acc_id              number(9, 0), -- GN added this 04/08/2011
            acc_num             varchar2(20 byte), -- GN added this 04/08/2011
            error_message       varchar2(100 byte), -- GN added this 04/08/2011
            batch_number        varchar2(50)
    );

-- Vanitha: 04/04/2011
    type claim_service_detail_row_t is record (
            service_date      varchar2(255),
            service_cost      varchar2(255),
            patient           varchar2(255),
            service_provider  varchar2(3200),
            provider_acc_num  varchar2(3200),
            service_code      varchar2(255),
            claim_line_number varchar2(255)
    );
    type claim_detail_table_t is
        table of claim_detail_row_t; -- Vanitha: 04/04/2011

    type claim_service_detail_table_t is
        table of claim_service_detail_row_t; -- Vanitha: 04/04/2011

-------------------------------------------------------------------
-- 1. MAIN METHOD WHICH PROCESS THE CLAIM FILE
-- This method execution populates claim header, claim detail and claim service tables - 837 file
-------------------------------------------------------------------
    procedure process_claim_file;

-------------------------------------------------------------------
--1a. This method inserts records into the claim header table
-------------------------------------------------------------------
    procedure insert_header_row (
        claim_edi_header_table claim_edi_header_type
    );

-------------------------------------------------------------------
--1b. This method inserts records into the claim detail table
-------------------------------------------------------------------
    procedure insert_detail_row (
        claim_edi_detail_table claim_edi_detail_type
    );

-------------------------------------------------------------------
--1c. This method inserts records into the claim service detail table
-------------------------------------------------------------------
    procedure insert_service_detail_row (
        claim_edi_service_detail_table claim_edi_service_detail_type
    );

-------------------------------------------------------------------
-- 2a. This method processes claim header records only
-------------------------------------------------------------------
    procedure process_claim_header (
        p_claim_header_id_out out claim_edi_header.claim_header_id%type
    );

-------------------------------------------------------------------
-- 2b. This method processes claim detail records only
-------------------------------------------------------------------
    procedure process_claim_detail (
        p_claim_header_id_in in claim_edi_header.claim_header_id%type
    );

-------------------------------------------------------------------
-- 3a. This method fetches header records only for processing
-------------------------------------------------------------------
    procedure get_claim_header_seg (
        p_rec_cntr_in         in number,
        p_begin_header_rec_in in number,
        p_end_header_rec_in   in number,
        p_header_row_out      out claim_edi_header_type,
        p_claim_header_id_out out claim_edi_header.claim_header_id%type
    );

-------------------------------------------------------------------
-- 4a. This method fetches claim detail's begin and end rows
-------------------------------------------------------------------
    function get_claim_det (
        p_from_row in number,
        p_to_row   in number
    ) return claim_detail_table_t
        pipelined
        deterministic;

-------------------------------------------------------------------
-- 4b. This method claim service detail's begin and end rows
-------------------------------------------------------------------
    function get_claim_service_det (
        p_from_row in number,
        p_to_row   in number
    ) return claim_service_detail_table_t
        pipelined
        deterministic;

-------------------------------------------------------------------
-- 5. This method gets person id for the given subscriber number -- Geetha added on 04/08/2011
-------------------------------------------------------------------
    function get_pers_id (
        p_sbscrbr_nmbr_in in claim_edi_detail.sbscrbr_nmbr%type
    ) return number;

-------------------------------------------------------------------
-- 6. This method gets account id and account number for a given person id -- Geetha added on 04/08/2011
-------------------------------------------------------------------
    procedure get_acc_details (
        p_pers_id_in  in person.pers_id%type,
        p_acc_id_out  out account.acc_id%type,
        p_acc_num_out out account.acc_num%type
    );

-------------------------------------------------------------------
-- 7. This method imports the EDI claims -- Geetha added on 04/09/2011
-------------------------------------------------------------------
    procedure import_edi_claims (
        p_user_id_in      in number,
        p_batch_number_in in varchar2
    );

end claim_edi;
/


-- sqlcl_snapshot {"hash":"fbf77931e43df960046c81fe89dffb427515d2b0","type":"PACKAGE_SPEC","name":"CLAIM_EDI","schemaName":"SAMQA","sxml":""}