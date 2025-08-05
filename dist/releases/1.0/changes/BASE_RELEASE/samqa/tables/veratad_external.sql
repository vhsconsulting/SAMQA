-- liquibase formatted sql
-- changeset SAMQA:1754374164261 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\veratad_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/veratad_external.sql:null:4451f64386bc7619e772a3dc0a172559cb487720:create

create table samqa.veratad_external (
    sequence_no           varchar2(80 byte),
    acc_num               varchar2(80 byte),
    enroll_source         varchar2(80 byte),
    first_name            varchar2(80 byte),
    middle_name           varchar2(80 byte),
    last_name             varchar2(80 byte),
    address               varchar2(80 byte),
    city                  varchar2(80 byte),
    state                 varchar2(80 byte),
    zip                   varchar2(80 byte),
    birth_date            varchar2(80 byte),
    dob_type              varchar2(80 byte),
    ssn                   varchar2(80 byte),
    status                varchar2(80 byte),
    message               varchar2(3200 byte),
    transaction_id        varchar2(80 byte),
    verification_date     varchar2(80 byte),
    age_code              varchar2(80 byte),
    age_text              varchar2(80 byte),
    deceased_code         varchar2(80 byte),
    deceased_text         varchar2(2000 byte),
    age_delta             varchar2(80 byte),
    ssn_code              varchar2(80 byte),
    ssn_text              varchar2(2000 byte),
    closest_first_name    varchar2(255 byte),
    closest_middle_name   varchar2(255 byte),
    closest_last_name     varchar2(255 byte),
    closest_street_num    varchar2(255 byte),
    closest_predirection  varchar2(255 byte),
    closest_street_name   varchar2(2000 byte),
    closest_postdirection varchar2(255 byte),
    closest_suffix        varchar2(255 byte),
    closest_box_des       varchar2(255 byte),
    closest_box_num       varchar2(255 byte),
    closest_route_des     varchar2(255 byte),
    closest_route_num     varchar2(255 byte),
    closest_unit_des      varchar2(255 byte),
    closest_unit_num      varchar2(255 byte),
    closest_city          varchar2(255 byte),
    closest_state         varchar2(255 byte),
    closest_zip           varchar2(255 byte),
    newest_first_name     varchar2(255 byte),
    newest_middle         varchar2(255 byte),
    newest_last_name      varchar2(255 byte),
    newest_street_num     varchar2(255 byte),
    newest_predirection   varchar2(255 byte),
    newest_street_name    varchar2(255 byte),
    newest_postdirection  varchar2(255 byte),
    newest_suffix         varchar2(255 byte),
    newest_box_des        varchar2(255 byte),
    newest_box_num        varchar2(255 byte),
    newest_route_des      varchar2(255 byte),
    newest_route_num      varchar2(255 byte),
    newest_unitdes        varchar2(255 byte),
    newest_unitnum        varchar2(255 byte),
    newest_city           varchar2(255 byte),
    newest_state          varchar2(255 byte),
    newest_zip            varchar2(255 byte),
    newest_date           varchar2(255 byte),
    ambiguous_code        varchar2(2000 byte),
    ambiguous_text        varchar2(2000 byte),
    ofac_code             varchar2(255 byte),
    ofac_text             varchar2(255 byte),
    ofacreference         varchar2(80 byte)
)
organization external ( type oracle_loader
    default directory webservice_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( veratad_inbound : 'VT_6799854_ssn.txt.out' )
) reject limit unlimited;

