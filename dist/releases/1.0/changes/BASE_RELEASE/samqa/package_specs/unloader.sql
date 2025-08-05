-- liquibase formatted sql
-- changeset SAMQA:1754374142461 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\unloader.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/unloader.sql:null:4adcb9deb78430ab124d76d6d91c3efb6eeb2afd:create

create or replace package samqa.unloader as
    function run (
        p_query      in varchar2 default null,
        p_cols       in varchar2 default '*',
        p_town       in varchar2 default user,
        p_tname      in varchar2,
        p_mode       in varchar2 default 'REPLACE',
        p_dir        in varchar2,
        p_filename   in varchar2,
        p_separator  in varchar2 default ',',
        p_enclosure  in varchar2 default '"',
        p_terminator in varchar2 default '|',
        p_ctl        in varchar2 default 'YES',
        p_header     in varchar2 default 'NO'
    ) return number;
    --
    function run (
        p_query      in varchar2 default null,
        p_cols       in varchar2 default '*',
        p_town       in varchar2 default user,
        p_tname      in varchar2,
        p_mode       in varchar2 default 'REPLACE',
        p_dbdir      in varchar2,
        p_filename   in varchar2,
        p_separator  in varchar2 default ',',
        p_enclosure  in varchar2 default '"',
        p_terminator in varchar2 default '|',
        p_ctl        in varchar2 default 'YES',
        p_header     in varchar2 default 'NO'
    ) return number;
    --
    function remove (
        p_dbdir    in varchar2,
        p_filename in varchar2
    ) return number;
    --
    procedure version;
    --
    procedure help;

end;
/

