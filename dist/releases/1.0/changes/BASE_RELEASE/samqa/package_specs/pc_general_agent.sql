-- liquibase formatted sql
-- changeset SAMQA:1754374137986 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_general_agent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_general_agent.sql:null:339d8f87f05e8396ab6af0be836780893b496a5c:create

create or replace package samqa.pc_general_agent is

      /*
      ??????????:
         ??? ???????????? ??????? ????????
      ?????????:
         25.07.2004 - SeF - ????????
      */
      -- ????????? ???????? ????? ?????? ? ??????? (PERSON, BROKER)

 -- Added by Jaggi for 9830
    type ga_info_row_rec is record (
            ga_id                  number,
            agency_name            varchar2(100),
            address                varchar2(2000),
            city                   varchar2(255),
            state                  varchar2(255),
            zip                    varchar2(255),
            phone                  varchar2(255),
            email                  varchar2(255),
            generate_combined_stmt varchar2(1),
            ga_lic                 varchar2(10)
    ); -- Added by Joshi for 12396  

    type ga_info_row_t is
        table of ga_info_row_rec;
    procedure cre_ga (
        agency_name_in           in general_agent.agency_name%type,
        contact_name_in          in general_agent.contact_name%type   ---rprabu 10/06/2020 8890
        ,
        address_in               in general_agent.address%type,
        city_in                  in general_agent.city%type,
        state_in                 in general_agent.state%type,
        zip_in                   in general_agent.zip%type,
        phone_day_in             in general_agent.phone%type,
        email_in                 in general_agent.email%type,
        start_date_in            in general_agent.start_date%type,
        end_date_in              in general_agent.end_date%type,
        ga_lic_in                in general_agent.ga_lic%type,
        ga_rate_in               in general_agent.ga_rate%type,
        note_in                  in general_agent.note%type,
        salesrep_id_in           in general_agent.salesrep_id%type,
        p_user_id                in number,
        p_generate_combined_stmt in varchar2   -- Added by jaggi #9830
        ,
        ga_id_out                out general_agent.ga_id%type
    );
      -- ????????? ?????????? ?????? ? ??????? (PERSON, BROKER)
    procedure upd_ga (
        ga_id_in                 in general_agent.ga_id%type,
        agency_name_in           in general_agent.agency_name%type,
        contact_name_in          in general_agent.contact_name%type   ---rprabu 10/06/2020 8890
        ,
        address_in               in general_agent.address%type,
        city_in                  in general_agent.city%type,
        state_in                 in general_agent.state%type,
        zip_in                   in general_agent.zip%type,
        phone_day_in             in general_agent.phone%type,
        email_in                 in general_agent.email%type,
        start_date_in            in general_agent.start_date%type,
        end_date_in              in general_agent.end_date%type,
        ga_lic_in                in general_agent.ga_lic%type,
        ga_rate_in               in general_agent.ga_rate%type,
        note_in                  in general_agent.note%type,
        salesrep_id_in           in general_agent.salesrep_id%type,
        p_user_id                in number,
        p_generate_combined_stmt in varchar2   -- Added by jaggi #9830
    );
      -- ????????? ???????? ?????? ? ??????? (PERSON, BROKER)
    procedure del_ga (
        ga_id_in  in general_agent.ga_id%type,
        p_user_id in number
    );

    function get_er_count (
        p_ga_id in number
    ) return number;

    function get_pers_count (
        p_ga_id      in number,
        p_acc_status in number
    ) return number;

    -- Added by rprabu for Ticket#8890
    -- Procedure to update the flg_agree column of the GA.
    -- After GA creation, for the first time GA login, user will be prompted with a message to agree/Disagree
    procedure upd_general_agent_flg_agree (
        p_ga_id     in number,
        p_flg_agree in varchar2
    );



    -- Added by rprabu for Ticket#8890
    procedure update_ga_online (
        p_ga_id         in general_agent.ga_id%type,
        p_first_name    in person.first_name%type,
        p_last_name     in person.last_name%type,
        p_address       in person.address%type,
        p_city          in person.city%type,
        p_state         in person.state%type,
        p_zip           in person.zip%type,
        p_phone         in person.phone_day%type,
        p_email         in person.email%type,
        p_agency_name   in broker.agency_name%type,
        p_user_id       in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    --------rprabu -3/08/2020 9141
    function get_ga_name (
        p_ga_id in number
    ) return varchar2;

    -- Pedning CLient Info ## added by rprabu 03/08/2020
    type get_pending_client_info_row_t is record (
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
            created_by         varchar2(300)   -- Added by Jaggi ##9793
            ,
            general_agent_name varchar2(300),
            general_agent_id   number,
            phone_number       varchar2(100),
            complete_flag      varchar2(1),
            industry_type      varchar2(2000),
            resubmit_flag      varchar2(1)
    );  -- added by jaggi #10431)
    type get_pending_client_info_t is
        table of get_pending_client_info_row_t;
    function get_pending_client_info (
        p_ga_id       in number,
        p_client_name varchar2,
        p_acct_type   varchar2,
        p_acct_status varchar2,
        p_broker_name varchar2
    ) return get_pending_client_info_t
        pipelined
        deterministic;

    function get_ga_info (
        p_ga_id in number
    ) return ga_info_row_t
        pipelined
        deterministic; -- JAggi 9830
    -- Added by Joshi for GA consolidated stmt
    function is_ga_consolidate_stmt_enabled (
        p_ga_id in number
    ) return varchar2;

-- Added by Swamy for Ticket#11364
    procedure get_ga_id (
        p_user_id     in number,
        p_entity_type out varchar2,
        p_ga_id       out number
    );

end pc_general_agent;
/

