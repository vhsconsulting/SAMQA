-- liquibase formatted sql
-- changeset SAMQA:1754374163797 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\toad_plan_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/toad_plan_table.sql:null:02501bea509044c4ecb22a75bf68866e5fb6b03a:create

create global temporary table samqa.toad_plan_table (
    statement_id      varchar2(30 byte),
    plan_id           number,
    timestamp         date,
    remarks           varchar2(4000 byte),
    operation         varchar2(30 byte),
    options           varchar2(255 byte),
    object_node       varchar2(128 byte),
    object_owner      varchar2(30 byte),
    object_name       varchar2(30 byte),
    object_alias      varchar2(65 byte),
    object_instance   number(*, 0),
    object_type       varchar2(30 byte),
    optimizer         varchar2(255 byte),
    search_columns    number,
    id                number(*, 0),
    parent_id         number(*, 0),
    depth             number(*, 0),
    position          number(*, 0),
    cost              number(*, 0),
    cardinality       number(*, 0),
    bytes             number(*, 0),
    other_tag         varchar2(255 byte),
    partition_start   varchar2(255 byte),
    partition_stop    varchar2(255 byte),
    partition_id      number(*, 0),
    other             long,
    distribution      varchar2(30 byte),
    cpu_cost          number(*, 0),
    io_cost           number(*, 0),
    temp_space        number(*, 0),
    access_predicates varchar2(4000 byte),
    filter_predicates varchar2(4000 byte),
    projection        varchar2(4000 byte),
    time              number(*, 0),
    qblock_name       varchar2(30 byte),
    other_xml         clob
) on commit preserve rows;

