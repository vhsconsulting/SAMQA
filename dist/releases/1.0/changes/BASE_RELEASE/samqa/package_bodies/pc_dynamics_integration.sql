-- liquibase formatted sql
-- changeset SAMQA:1754374003016 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_dynamics_integration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_dynamics_integration.sql:null:b06b483fce4eda286d02a4b051fb2668657107aa:create

create or replace package body samqa.pc_dynamics_integration as

    function get_auth_token (
        p_env_type  in varchar2,
        p_tenant_id in varchar2
    ) return varchar2 is
    begin
        return null;
    end get_auth_token;

    function call_api (
        p_entity_name in varchar2,
        p_data        in clob
    ) return clob is
    begin
        return null;
    end call_api;

    function get_account_data (
        p_acc_id in number
    ) return clob is
        l_clob clob;
    begin
        select
            json_array(
                json_object(
                    'importsequencenumber' value b.acc_id,
                            'name' value replace(a.name,
                                                 chr(10)),
                            'accountcategorycode' value 1
                                 --    , 'accountclassificationcode' value 'sam'
                            ,
                            'address1_addresstypecode' value '3',
                            'address1_line1' value a.address,
                            'address1_city' value a.city,
                            'address1_stateorprovince' value a.state,
                            'address1_postalcode' value a.zip,
                            'address1_country' value 'usa',
                            'accountnumber' value b.acc_num,
                            'emailaddress1' value a.entrp_email,
                            'telephone1' value a.entrp_phones,
                            'fax' value a.entrp_fax,
                            'new_AccountType@odata.bind' value '/new_accounttypes(new_accounttypecode='''
                                                               || b.account_type
                                                               || ''')'
                                  --   , 'industrycode' value industry_type 
                                                               ,
                            'numberofemployees' value no_of_ees,
                            'createdon' value to_char(b.creation_date, 'mm/dd/yyyy'),
                            'modifiedon' value to_char(b.last_update_date, 'mm/dd/yyyy'),
                            'new_AccountManager@odata.bind' value replace((
                        select
                            '/systemusers(internalemailaddress='''
                            || e.email
                            || ''',incomingemaildeliverymethod=2)'
                        from
                            salesrep a,
                            employee e
                        where
                                a.emp_id = e.emp_id
                            and a.salesrep_id = b.am_id
                    ),
                                                                          chr(10),
                                                                          ''),
                            'arm_GeneralAgent@odata.bind' value '/arm_generalagents(arm_agentid='''
                                                                || nvl(b.ga_id, 0)
                                                                || ''')',
                            'arm_BrokerageofRecord@odata.bind' value '/arm_brokerages(arm_brokerid='''
                                                                     || b.broker_id
                                                                     || ''')',
                            'arm_taxid' value a.entrp_code,
                            'arm_totaleligible' value a.no_of_eligible,
                            'businesstypecode' value a.irs_business_code,
                            'statecode' value 1
                )
            ) data_r
        into l_clob
        from
            enterprise a,
            account    b
        where
                a.entrp_id = b.entrp_id
            and b.acc_id = p_acc_id;

        return l_clob;
    end get_account_data;

    function get_broker_data (
        p_broker_id in number
    ) return clob is
        l_clob clob;
    begin
        select
            json_array(
                json_object(
                    'arm_brokerid' value to_char(b.broker_id)
                                                                    --    ,'arm_brokerorigin'   value   B.AGENCY_NAME how to get this value
                    ,
                            'arm_brokerstatus' value '173000001',
                            'arm_licenseid' value b.broker_lic,
                            'arm_name' value p.first_name
                                             || ' '
                                             || p.last_name
                                             || ' '
                                             || b.agency_name,
                            'arm_phone' value p.phone_day,
                            'arm_SalesRep@odata.bind' value replace((
                        select
                            '/systemusers(internalemailaddress='''
                            || e.email
                            || ''',incomingemaildeliverymethod=2)'
                        from
                            salesrep a,
                            employee e
                        where
                                a.emp_id = e.emp_id
                            and a.salesrep_id = nvl(b.salesrep_id, 6131)
                    ),
                                                                    chr(10),
                                                                    '')
                                                                    --    ,'arm_SalesRepName'   value   pc_account.get_salesrep_name(b.SALESREP_ID) --need to get this value
                                                                    ,
                            'createdon' value b.creation_date,
                            'emailaddress' value p.email,
                            'ownerid@odata.bind' value '/systemusers(internalemailaddress=''dynamicsadmin@sterlingadministration.com''' || ',incomingemaildeliverymethod=2)'
                            ,
                            'modifiedon' value b.last_update_date
                )
            )
        into l_clob
        from
            broker b,
            person p
        where
                p.pers_id = b.broker_id
            and b.broker_id = p_broker_id;

        return l_clob;
    end get_broker_data;

    function get_ga_data (
        p_ga_id in number
    ) return clob is
        l_clob clob;
    begin
        select
            json_array(
                json_object(
                    'arm_agentid' value to_char(ga_id)
                        --    ,'arm_brokerorigin'   value   B.AGENCY_NAME how to get this value
                    ,
                            'arm_name' value agency_name,
                            'arm_state' value state,
                            'arm_city' value city,
                            'arm_address' value address,
                            'createdon' value creation_date,
                            'modifiedon' value last_update_date
                )
            )
        into l_clob
        from
            general_agent
        where
            ( p_ga_id is not null
              and ga_id = p_ga_id );

        return l_clob;
    end get_ga_data;

    function get_update_account_data (
        p_acc_id in number
    ) return clob is
        l_clob clob;
    begin
        return l_clob;
    end get_update_account_data;

    function get_update_broker_data (
        p_acc_id in number
    ) return clob is
        l_clob clob;
    begin
        return l_clob;
    end get_update_broker_data;

end pc_dynamics_integration;
/

