--------------------------------------------------------
--  File created - Wednesday-August-08-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Type IDS_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE IDS_T 
AS TABLE OF NUMBER;

/
--------------------------------------------------------
--  DDL for Type LUX_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE LUX_T AS OBJECT 
( 
  League_Short_Name VARCHAR2(8 CHAR),
  Club_Name VARCHAR2(128 CHAR),
  The_Tax NUMBER
)

/
--------------------------------------------------------
--  DDL for Type LUX_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE LUX_TABLE 
AS TABLE OF LUX_T

/
--------------------------------------------------------
--  DDL for Type TOP_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE TOP_T IS 
OBJECT (
        club VARCHAR2(128 CHAR),
        player VARCHAR(128 CHAR),
        pos_name VARCHAR(8 CHAR),
        val NUMBER
       )

/
--------------------------------------------------------
--  DDL for Type TOP_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE TOP_TABLE IS TABLE OF top_t

/
--------------------------------------------------------
--  DDL for Sequence CLUB_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  CLUB_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 81 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Sequence CONTRACT_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  CONTRACT_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 821 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Sequence LEAGUE_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  LEAGUE_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Sequence PLAYER_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  PLAYER_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1041 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Sequence POSITION_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  POSITION_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Sequence SEASON_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  SEASON_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Sequence TRADE_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  TRADE_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 61 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Table BUDGET
--------------------------------------------------------

  CREATE TABLE BUDGET 
   (	LEAGUE_ID NUMBER(*,0), 
	SEASON_ID NUMBER(*,0), 
	AMOUNT NUMBER(*,0)
   ) ;

   COMMENT ON TABLE BUDGET  IS 'Budget amount of each League for all the Seasons';
--------------------------------------------------------
--  DDL for Table CLUB
--------------------------------------------------------

  CREATE TABLE CLUB 
   (	ID NUMBER(*,0), 
	NAME VARCHAR2(128 CHAR)
   ) ;

   COMMENT ON TABLE CLUB  IS 'The team which takes part in the game';
--------------------------------------------------------
--  DDL for Table CONTRACT
--------------------------------------------------------

  CREATE TABLE CONTRACT 
   (	ID NUMBER(*,0), 
	CLUB_ID NUMBER(*,0), 
	PLAYER_ID NUMBER(*,0), 
	DATE_START DATE DEFAULT sysdate, 
	DATE_END DATE, 
	VALUE NUMBER(*,0), 
	TRADE_ID NUMBER(*,0)
   ) ;

   COMMENT ON TABLE CONTRACT  IS 'Agreement of the Player to play for the Club for specific reason';
--------------------------------------------------------
--  DDL for Table LEAGUE
--------------------------------------------------------

  CREATE TABLE LEAGUE 
   (	ID NUMBER(*,0), 
	SHORT_NAME VARCHAR2(8 CHAR), 
	FULL_NAME VARCHAR2(128 CHAR)
   ) ;

   COMMENT ON TABLE LEAGUE  IS 'Lists all the possible Leagues';
--------------------------------------------------------
--  DDL for Table LEAGUE_SEASON_CLUB_REL
--------------------------------------------------------

  CREATE TABLE LEAGUE_SEASON_CLUB_REL 
   (	SEASON_ID NUMBER(*,0), 
	LEAGUE_ID NUMBER(*,0), 
	CLUB_ID NUMBER(*,0)
   ) ;

   COMMENT ON TABLE LEAGUE_SEASON_CLUB_REL  IS 'Defines which Season is Contract for';
--------------------------------------------------------
--  DDL for Table LUXURY_TAX
--------------------------------------------------------

  CREATE TABLE LUXURY_TAX 
   (	DATE_MONTH DATE, 
	LEAGUE_ID NUMBER(*,0), 
	CLUB_ID NUMBER(*,0), 
	THE_TAX NUMBER
   ) ;
--------------------------------------------------------
--  DDL for Table PLAYER
--------------------------------------------------------

  CREATE TABLE PLAYER 
   (	ID NUMBER(*,0), 
	NAME VARCHAR2(128 CHAR), 
	IS_INJURED NUMBER(1,0) DEFAULT 0
   ) ;

   COMMENT ON TABLE PLAYER  IS 'All possible players that have ever played any of the leagues';
--------------------------------------------------------
--  DDL for Table PLAYER_POSITION_REL
--------------------------------------------------------

  CREATE TABLE PLAYER_POSITION_REL 
   (	PLAYER_ID NUMBER(*,0), 
	POSITION_ID NUMBER(*,0)
   ) ;

   COMMENT ON TABLE PLAYER_POSITION_REL  IS 'Specific Position that Player is playing in for the team (Club)';
--------------------------------------------------------
--  DDL for Table POSITION
--------------------------------------------------------

  CREATE TABLE POSITION 
   (	ID NUMBER(*,0), 
	SHORT_NAME VARCHAR2(8 CHAR), 
	FULL_NAME VARCHAR2(64)
   ) ;
--------------------------------------------------------
--  DDL for Table SEASON
--------------------------------------------------------

  CREATE TABLE SEASON 
   (	ID NUMBER(*,0), 
	YEAR NUMBER(*,0), 
	DATE_START DATE, 
	DATE_END DATE, 
	TEAM_SIZE NUMBER(*,0) DEFAULT 15
   ) ;

   COMMENT ON TABLE SEASON  IS 'Dictionary of the Seasons';
--------------------------------------------------------
--  DDL for Table TRADE
--------------------------------------------------------

  CREATE TABLE TRADE 
   (	TRADE_ID NUMBER(*,0), 
	FROM_CLUB_ID NUMBER(*,0), 
	TO_CLUB_ID NUMBER(*,0)
   ) ;
--------------------------------------------------------
--  DDL for View V_LUXURY_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE VIEW V_LUXURY_TAX (SEASON_ID, SEASON_YEAR, LEAGUE_ID, LEAGUE_NAME, CLUB_ID, CLUB_NAME, THE_TAX) AS 
  WITH team_budget as (
       SELECT s.id as season_id,
              s.year as season_year,
              l.id AS league_id,
              l.short_name AS league_name,
              c.id AS club_id,
              c.name AS club_name,
              b.amount,
              sum(co.value) AS club_budget
         FROM CLUB c,
              CONTRACT co,
              LEAGUE_SEASON_CLUB_REL lsc,
              LEAGUE l,
              BUDGET b,
              SEASON s
        WHERE s.year = EXTRACT(YEAR FROM sysdate) + 1
          AND co.club_id = c.id
          AND sysdate BETWEEN co.date_start and co.date_end
          AND lsc.club_id = c.id
          AND lsc.league_id = l.id
          AND lsc.season_id = b.season_id
          AND b.season_id = s.id
          AND b.league_id = l.id
        GROUP BY l.id,
              l.short_name,
              c.id,
              c.name,
              b.amount,
              s.id,
              s.year
       )
SELECT season_id,
       season_year,
       league_id,
       league_name,
       club_id,
       club_name,
       club_budget - amount as the_tax
  FROM team_budget
 WHERE club_budget > amount;
--------------------------------------------------------
--  DDL for View V_TEAM_OUT_OF_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE VIEW V_TEAM_OUT_OF_BUDGET (SEASON_YEAR, CLUB_NAME) AS 
  SELECT season_year,
       club_name
  FROM v_luxury_tax;
--------------------------------------------------------
--  DDL for View V_TOP_10_PLAYERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE VIEW V_TOP_10_PLAYERS (PLAYER_NAME, BUDGET) AS 
  SELECT p.name AS player_name,
       to_char(sum(co.value), '999,999,999,999') AS budget 
  FROM PLAYER p,
       CONTRACT co
 WHERE p.id = co.player_id
   AND sysdate BETWEEN co.date_start AND co.date_end
 GROUP BY p.name
 ORDER BY budget DESC
 FETCH FIRST 10 ROW ONLY;
--------------------------------------------------------
--  DDL for View V_TOP_10_TEAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE VIEW V_TOP_10_TEAMS (CLUB_NAME, BUDGET) AS 
  SELECT c.name AS club_name,
       to_char(sum(co.value), '999,999,999,999') AS budget 
  FROM CLUB c,
       CONTRACT co
 WHERE c.id = co.club_id
   AND sysdate BETWEEN co.date_start AND co.date_end
 GROUP BY c.name
 ORDER BY budget DESC
 FETCH FIRST 10 ROW ONLY;
--------------------------------------------------------
--  DDL for Index POSITION_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX POSITION_PK ON POSITION (ID) 
  ;
--------------------------------------------------------
--  DDL for Index CONTRACT_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX CONTRACT_PK ON CONTRACT (ID) 
  ;
--------------------------------------------------------
--  DDL for Index PLAYER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX PLAYER_PK ON PLAYER (ID) 
  ;
--------------------------------------------------------
--  DDL for Index CONTRACT_CLUB_PLAYER_INDX
--------------------------------------------------------

  CREATE INDEX CONTRACT_CLUB_PLAYER_INDX ON CONTRACT (CLUB_ID, PLAYER_ID) 
  ;
--------------------------------------------------------
--  DDL for Index LUXURY_TAX_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX LUXURY_TAX_PK ON LUXURY_TAX (LEAGUE_ID, CLUB_ID, DATE_MONTH) 
  ;
--------------------------------------------------------
--  DDL for Index PLAYER_POSITION_REL_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX PLAYER_POSITION_REL_PK ON PLAYER_POSITION_REL (PLAYER_ID, POSITION_ID) 
  ;
--------------------------------------------------------
--  DDL for Index LEAGUE_SEASON_CLUB_REL_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX LEAGUE_SEASON_CLUB_REL_PK ON LEAGUE_SEASON_CLUB_REL (SEASON_ID, LEAGUE_ID, CLUB_ID) 
  ;
--------------------------------------------------------
--  DDL for Index CLUB_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX CLUB_PK ON CLUB (ID) 
  ;
--------------------------------------------------------
--  DDL for Index LEAGUE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX LEAGUE_PK ON LEAGUE (ID) 
  ;
--------------------------------------------------------
--  DDL for Index BUDGET_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX BUDGET_PK ON BUDGET (LEAGUE_ID, SEASON_ID) 
  ;
--------------------------------------------------------
--  DDL for Index TRADE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX TRADE_PK ON TRADE (TRADE_ID) 
  ;
--------------------------------------------------------
--  DDL for Index SEASON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX SEASON_PK ON SEASON (ID) 
  ;
--------------------------------------------------------
--  Constraints for Table POSITION
--------------------------------------------------------

  ALTER TABLE POSITION MODIFY (ID NOT NULL ENABLE);
  ALTER TABLE POSITION ADD CONSTRAINT POSITION_PK PRIMARY KEY (ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table BUDGET
--------------------------------------------------------

  ALTER TABLE BUDGET ADD CONSTRAINT BUDGET_PK PRIMARY KEY (LEAGUE_ID, SEASON_ID)
  USING INDEX  ENABLE;
  ALTER TABLE BUDGET MODIFY (LEAGUE_ID NOT NULL ENABLE);
  ALTER TABLE BUDGET MODIFY (SEASON_ID NOT NULL ENABLE);
  ALTER TABLE BUDGET MODIFY (AMOUNT NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table CONTRACT
--------------------------------------------------------

  ALTER TABLE CONTRACT MODIFY (ID NOT NULL ENABLE);
  ALTER TABLE CONTRACT MODIFY (CLUB_ID NOT NULL ENABLE);
  ALTER TABLE CONTRACT MODIFY (PLAYER_ID NOT NULL ENABLE);
  ALTER TABLE CONTRACT MODIFY (DATE_START NOT NULL ENABLE);
  ALTER TABLE CONTRACT MODIFY (VALUE NOT NULL ENABLE);
  ALTER TABLE CONTRACT ADD CONSTRAINT CONTRACT_PK PRIMARY KEY (ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table LEAGUE
--------------------------------------------------------

  ALTER TABLE LEAGUE MODIFY (ID NOT NULL ENABLE);
  ALTER TABLE LEAGUE ADD CONSTRAINT LEAGUE_PK PRIMARY KEY (ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table SEASON
--------------------------------------------------------

  ALTER TABLE SEASON MODIFY (ID NOT NULL ENABLE);
  ALTER TABLE SEASON MODIFY (YEAR NOT NULL ENABLE);
  ALTER TABLE SEASON MODIFY (DATE_START NOT NULL ENABLE);
  ALTER TABLE SEASON MODIFY (DATE_END NOT NULL ENABLE);
  ALTER TABLE SEASON MODIFY (TEAM_SIZE NOT NULL ENABLE);
  ALTER TABLE SEASON ADD CONSTRAINT SEASON_PK PRIMARY KEY (ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table PLAYER
--------------------------------------------------------

  ALTER TABLE PLAYER MODIFY (ID NOT NULL ENABLE);
  ALTER TABLE PLAYER ADD CONSTRAINT PLAYER_PK PRIMARY KEY (ID)
  USING INDEX  ENABLE;
  ALTER TABLE PLAYER ADD CONSTRAINT PLAYER_INJURED_CHK CHECK (is_injured IN (0, 1)) ENABLE;
--------------------------------------------------------
--  Constraints for Table PLAYER_POSITION_REL
--------------------------------------------------------

  ALTER TABLE PLAYER_POSITION_REL MODIFY (PLAYER_ID NOT NULL ENABLE);
  ALTER TABLE PLAYER_POSITION_REL MODIFY (POSITION_ID NOT NULL ENABLE);
  ALTER TABLE PLAYER_POSITION_REL ADD CONSTRAINT PLAYER_POSITION_REL_PK PRIMARY KEY (PLAYER_ID, POSITION_ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table LUXURY_TAX
--------------------------------------------------------

  ALTER TABLE LUXURY_TAX MODIFY (LEAGUE_ID NOT NULL ENABLE);
  ALTER TABLE LUXURY_TAX MODIFY (CLUB_ID NOT NULL ENABLE);
  ALTER TABLE LUXURY_TAX MODIFY (DATE_MONTH NOT NULL ENABLE);
  ALTER TABLE LUXURY_TAX ADD CONSTRAINT LUXURY_TAX_PK PRIMARY KEY (LEAGUE_ID, CLUB_ID, DATE_MONTH)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table TRADE
--------------------------------------------------------

  ALTER TABLE TRADE MODIFY (TRADE_ID NOT NULL ENABLE);
  ALTER TABLE TRADE ADD CONSTRAINT TRADE_PK PRIMARY KEY (TRADE_ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table CLUB
--------------------------------------------------------

  ALTER TABLE CLUB MODIFY (ID NOT NULL ENABLE);
  ALTER TABLE CLUB ADD CONSTRAINT CLUB_PK PRIMARY KEY (ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table LEAGUE_SEASON_CLUB_REL
--------------------------------------------------------

  ALTER TABLE LEAGUE_SEASON_CLUB_REL MODIFY (SEASON_ID NOT NULL ENABLE);
  ALTER TABLE LEAGUE_SEASON_CLUB_REL MODIFY (LEAGUE_ID NOT NULL ENABLE);
  ALTER TABLE LEAGUE_SEASON_CLUB_REL MODIFY (CLUB_ID NOT NULL ENABLE);
  ALTER TABLE LEAGUE_SEASON_CLUB_REL ADD CONSTRAINT LEAGUE_SEASON_CLUB_REL_PK PRIMARY KEY (SEASON_ID, LEAGUE_ID, CLUB_ID)
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table BUDGET
--------------------------------------------------------

  ALTER TABLE BUDGET ADD CONSTRAINT BUDGET_LEAGUE_FK FOREIGN KEY (LEAGUE_ID)
	  REFERENCES LEAGUE (ID) ENABLE;
  ALTER TABLE BUDGET ADD CONSTRAINT BUDGET_SEASON_FK FOREIGN KEY (SEASON_ID)
	  REFERENCES SEASON (ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table CONTRACT
--------------------------------------------------------

  ALTER TABLE CONTRACT ADD CONSTRAINT CONTRACT_CLUB_FK FOREIGN KEY (CLUB_ID)
	  REFERENCES CLUB (ID) ENABLE;
  ALTER TABLE CONTRACT ADD CONSTRAINT CONTRACT_PLAYER_FK FOREIGN KEY (PLAYER_ID)
	  REFERENCES PLAYER (ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table LEAGUE_SEASON_CLUB_REL
--------------------------------------------------------

  ALTER TABLE LEAGUE_SEASON_CLUB_REL ADD CONSTRAINT LEAGUE_SEASON_CLUB_CLUB_FK FOREIGN KEY (CLUB_ID)
	  REFERENCES CLUB (ID) ENABLE;
  ALTER TABLE LEAGUE_SEASON_CLUB_REL ADD CONSTRAINT LEAGUE_SEASON_CLUB_LEAGUE_FK FOREIGN KEY (LEAGUE_ID)
	  REFERENCES LEAGUE (ID) ENABLE;
  ALTER TABLE LEAGUE_SEASON_CLUB_REL ADD CONSTRAINT LEAGUE_SEASON_CLUB_SEASON_FK FOREIGN KEY (SEASON_ID)
	  REFERENCES SEASON (ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table LUXURY_TAX
--------------------------------------------------------

  ALTER TABLE LUXURY_TAX ADD CONSTRAINT LUXURY_TAX_CLUB_FK FOREIGN KEY (CLUB_ID)
	  REFERENCES CLUB (ID) ENABLE;
  ALTER TABLE LUXURY_TAX ADD CONSTRAINT LUXURY_TAX_LEAGUE_FK FOREIGN KEY (LEAGUE_ID)
	  REFERENCES LEAGUE (ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table PLAYER_POSITION_REL
--------------------------------------------------------

  ALTER TABLE PLAYER_POSITION_REL ADD CONSTRAINT PLPOS_PLAYER_FK FOREIGN KEY (PLAYER_ID)
	  REFERENCES PLAYER (ID) ENABLE;
  ALTER TABLE PLAYER_POSITION_REL ADD CONSTRAINT PLPOS_POSITION_FK FOREIGN KEY (POSITION_ID)
	  REFERENCES POSITION (ID) ENABLE;
--------------------------------------------------------
--  DDL for Trigger CLUB_ID_INCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER CLUB_ID_INCR 
   before insert on CLUB 
   for each row 
begin  
   if inserting then 
      if :NEW.ID is null then 
         select CLUB_SEQ.nextval into :NEW.ID from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER CLUB_ID_INCR ENABLE;
--------------------------------------------------------
--  DDL for Trigger CONTRACT_ID_INCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER CONTRACT_ID_INCR 
   before insert on CONTRACT 
   for each row 
begin  
   if inserting then 
      if :NEW.ID is null then 
         select CONTRACT_SEQ.nextval into :NEW.ID from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER CONTRACT_ID_INCR ENABLE;
--------------------------------------------------------
--  DDL for Trigger LEAGUE_ID_INCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER LEAGUE_ID_INCR 
   before insert on LEAGUE 
   for each row 
begin  
   if inserting then 
      if :NEW.ID is null then 
         select LEAGUE_SEQ.nextval into :NEW.ID from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER LEAGUE_ID_INCR ENABLE;
--------------------------------------------------------
--  DDL for Trigger PLAYER_ID_INCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER PLAYER_ID_INCR 
   before insert on PLAYER 
   for each row 
begin  
   if inserting then 
      if :NEW.ID is null then 
         select PLAYER_SEQ.nextval into :NEW.ID from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER PLAYER_ID_INCR ENABLE;
--------------------------------------------------------
--  DDL for Trigger POSITION_ID_INCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER POSITION_ID_INCR 
   before insert on POSITION 
   for each row 
begin  
   if inserting then 
      if :NEW.ID is null then 
         select POSITION_SEQ.nextval into :NEW.ID from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER POSITION_ID_INCR ENABLE;
--------------------------------------------------------
--  DDL for Trigger SEASON_ID_INCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER SEASON_ID_INCR 
   before insert on SEASON 
   for each row 
begin  
   if inserting then 
      if :NEW.ID is null then 
         select SEASON_SEQ.nextval into :NEW.ID from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER SEASON_ID_INCR ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRADE_ID_INCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER TRADE_ID_INCR 
   before insert on TRADE 
   for each row 
begin  
   if inserting then 
      if :NEW.TRADE_ID is null then 
         select TRADE_SEQ.nextval into :NEW.TRADE_ID from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER TRADE_ID_INCR ENABLE;
--------------------------------------------------------
--  DDL for Package BLMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BLMS AS 

  PROCEDURE Injury(v_id NUMBER, v_is_injured NUMBER);
  /*Places/removes a player on/from an injury list.*/
  
  PROCEDURE Trade(p_from_id NUMBER, p_to_id NUMBER, p_ids IDS_T);
  /*Creates a trade between two teams*/
  
  FUNCTION TopPlayers(p_club CLUB.name%TYPE) RETURN top_table;
  /*Provide an information of the most expensive starting lineup for a specific team*/
  
  FUNCTION LuxuryTax RETURN lux_table;
  /*Provides monthly validation if some of the clubs breached a contract limit*/
  
END BLMS;

/
--------------------------------------------------------
--  DDL for Package Body BLMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY BLMS AS 
  

  PROCEDURE INJURY(v_id NUMBER, v_is_injured NUMBER /*Only 0 and 1 is accepted*/) AS
  BEGIN    
    UPDATE PLAYER p
       SET p.is_injured = v_is_injured
     WHERE p.id = v_id;
   COMMIT;
  END INJURY;
  
  PROCEDURE TRADE(p_from_id NUMBER, p_to_id NUMBER, p_ids IDS_T) AS
    contract_value_from NUMBER;
    contract_value_to NUMBER;
    v_team_size SEASON.TEAM_SIZE%TYPE;
    v_aftr_trade_from NUMBER;
    v_aftr_trade_to NUMBER;
    v_trade_id NUMBER;
    TYPE contract_type IS TABLE OF CONTRACT%ROWTYPE;
    tmp_contract contract_type;
  BEGIN
    dbms_output.enable(100000);
    -- Check if the overall trade summ differs less than 20%
    SELECT SUM(value)
      INTO contract_value_from
      FROM CONTRACT
     WHERE player_id IN (SELECT * FROM TABLE(p_ids))
       AND club_id IN (p_from_id)
     GROUP BY club_id;
    SELECT SUM(value)
      INTO contract_value_to
      FROM CONTRACT
     WHERE player_id IN (SELECT * FROM TABLE(p_ids))
       AND club_id IN (p_to_id)
     GROUP BY club_id;
    IF ABS( (contract_value_from / contract_value_to) - (contract_value_to / contract_value_from) ) > 44/120 THEN 
        dbms_output.put_line('Trade amount difference is more than 20%, it is not eligible!');
        RETURN;
    END IF;
    
    -- Check if the teams have enough empty spots on a roster
    SELECT DISTINCT team_size 
      INTO v_team_size
      FROM SEASON
     WHERE EXTRACT(YEAR FROM SYSDATE) + 1 = year;
    
    WITH trade_date AS (
                        SELECT c1.club_id AS club1,
                               COUNT(DISTINCT c1.player_id)  total_cnt1,
                               COUNT(DISTINCT CASE WHEN c1.player_id IN (SELECT * FROM TABLE(p_ids)) THEN c1.player_id ELSE NULL END)  trade_cnt1, 
                               c2.club_id  club2,
                               COUNT(DISTINCT c2.player_id) total_cnt2,
                               COUNT(DISTINCT CASE WHEN c2.player_id IN (SELECT * FROM TABLE(p_ids)) THEN c2.player_id ELSE NULL END)  trade_cnt2
                          FROM CONTRACT c1,
                               CONTRACT c2
                         WHERE c1.club_id = p_from_id
                           AND c2.club_id = p_to_id
                           AND sysdate BETWEEN c1.date_start and c1.date_end
                           AND sysdate BETWEEN c2.date_start and c2.date_end
                         GROUP BY c1.club_id, c2.club_id
                       )
    SELECT total_cnt1 - trade_cnt2 + trade_cnt1,
           total_cnt2 - trade_cnt1 + trade_cnt2 
      INTO v_aftr_trade_from,
           v_aftr_trade_to
      FROM trade_date;
    IF v_aftr_trade_from > v_team_size THEN
      dbms_output.put_line('First team has no empty spot  available on a team roster. This trade is not eligible!');
      RETURN;
    END IF;
    IF v_aftr_trade_to > v_team_size THEN
      dbms_output.put_line('Second team has no empty spot  available on a team roster. This trade is not eligible!');
      RETURN;
    END IF;
    
    -- Placing Trade
    v_trade_id := TRADE_SEQ.NEXTVAL;
    INSERT INTO TRADE (trade_id, from_club_id, to_club_id) VALUES (v_trade_id, p_from_id, p_to_id);
    
    -- Storing records for insert
    SELECT *
      BULK COLLECT INTO tmp_contract
      FROM CONTRACT 
     WHERE club_id IN (p_from_id, p_to_id)
       AND player_id IN (SELECT * FROM TABLE(p_ids))
       AND sysdate BETWEEN date_start AND date_end;     
    
    -- Closing current contracts
    UPDATE CONTRACT 
       SET date_end = (SYSDATE-1)
     WHERE id IN (
                  SELECT id
                    FROM CONTRACT 
                   WHERE club_id IN (p_from_id, p_to_id)
                     AND player_id IN (SELECT * FROM TABLE(p_ids))
                     AND sysdate BETWEEN date_start AND date_end
                 );
     
    -- Placing new contracts
    FOR i IN tmp_contract.FIRST..tmp_contract.LAST
    LOOP
      INSERT INTO CONTRACT (club_id, player_id, date_start, date_end, value, trade_id)
      VALUES (
              CASE tmp_contract(i).club_id
                WHEN p_from_id THEN p_to_id
                ELSE p_from_id
              END,
              tmp_contract(i).player_id,
              sysdate,
              tmp_contract(i).date_end,
              tmp_contract(i).value,
              v_trade_id
             );
       dbms_output.put_line('Club '||tmp_contract(i).club_id||' sold Player '||tmp_contract(i).player_id||' to Club '||CASE tmp_contract(i).club_id WHEN p_from_id THEN p_to_id ELSE p_from_id END);
    END LOOP;
    COMMIT;
    
    
  END TRADE;
  
FUNCTION TopPlayers(p_club CLUB.name%TYPE) RETURN top_table AS
    pre_rslt top_table;
    rslt top_table := top_table();
    i NUMBER;
    pos_cnt NUMBER;
    dist_pos NUMBER;
    player_cnt NUMBER;
    CURSOR rslt_cursor IS 
      SELECT club,
             player,
             pos_name, 
             COUNT(pos_name) OVER(PARTITION BY pos_name) as pos_rnk,
             val
        FROM TABLE(pre_rslt)
       ORDER BY pos_rnk ASC, pos_name ASC, val DESC;
  BEGIN
    i := 1;
    -- Getting distinct count of the Positions
    SELECT COUNT(DISTINCT id)
      INTO pos_cnt
      FROM POSITION;
      
    -- Gathering top players which may fill all Positions
    LOOP
      SELECT TOP_T(club,
             player,
             short_name,
             val)
        BULK COLLECT INTO pre_rslt
       FROM (
             SELECT c.id, c.name AS club,
                    p.name AS player,
                    po.short_name,
                    count( po.id) OVER( PARTITION BY c.id, p.id) AS pos_cnt,
                    co.value AS val,
                    DENSE_RANK() OVER(PARTITION BY c.id ORDER BY co.value DESC) AS rnk
               FROM CLUB c,
                    CONTRACT co,
                    PLAYER p,
                    PLAYER_POSITION_REL pp,
                    POSITION po
              WHERE c.id = co.club_id
                AND sysdate BETWEEN co.date_start and co.date_end
                AND co.player_id = p.id
                AND pp.player_id = p.id
                AND pp.position_id = po.id
                AND p.is_injured = 0
              ORDER BY c.name, 
                    co.value DESC
            )
      WHERE club = p_club
        AND rnk <= i;

      SELECT COUNT(DISTINCT pos_name)
        INTO dist_pos
        FROM TABLE(pre_rslt);
      SELECT COUNT(DISTINCT player)
        INTO player_cnt
        FROM TABLE(pre_rslt);
        
      EXIT WHEN pos_cnt = dist_pos AND player_cnt = pos_cnt;  
      i := i + 1;
    END LOOP;
    
    
    -- Filtering out Players to have exact team
    rslt.extend(5);
    i := 1;
    FOR c IN rslt_cursor
    LOOP
      SELECT COUNT(*)
        INTO pos_cnt
        FROM TABLE(rslt)
       WHERE c.pos_name = pos_name;
      SELECT COUNT(*)
        INTO player_cnt
        FROM TABLE(rslt)
       WHERE c.player = player;
       
      IF pos_cnt = 0 AND player_cnt = 0 THEN
         rslt(i) := top_t(c.club, c.player, c.pos_name, c.val);
         i := i + 1;
      END IF;
      
    END LOOP;
    
    RETURN rslt;
    
  END TopPlayers;
  
FUNCTION LuxuryTax RETURN lux_table AS
PRAGMA AUTONOMOUS_TRANSACTION;
  rslt lux_table;
BEGIN
  SELECT lux_t(league_name,
         club_name,
         the_tax)
    BULK COLLECT INTO rslt
    FROM V_LUXURY_TAX;
  DELETE 
    FROM LUXURY_TAX 
   WHERE date_month = TRUNC(sysdate) - (TO_NUMBER(TO_CHAR(sysdate,'DD')) - 1);
  INSERT INTO LUXURY_TAX
  SELECT TRUNC(sysdate) - (TO_NUMBER(TO_CHAR(sysdate,'DD')) - 1) as date_month,
         league_id,
         club_id,
         the_tax
    FROM v_luxury_tax;
  COMMIT;     
    
  RETURN rslt;  
END LuxuryTax;

  
END BLMS;

/
--------------------------------------------------------
--  DDL for Procedure INITIALIZE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE INITIALIZE AS 
BEGIN
  init_data;
  init_relations;
END INITIALIZE;

/
--------------------------------------------------------
--  DDL for Procedure INIT_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE INIT_DATA AS 
BEGIN
  -- Truncating tables
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE PLAYER_POSITION_REL';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE SEASON_CONTRACT_REL';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE CONTRACT';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE BUDGET';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE PLAYER';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE CLUB';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE POSITION';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE SEASON';
--  EXECUTE IMMEDIATE 'TRUNCATE TABLE LEAGUE';
  
  -- Adding Positions
  INSERT INTO POSITION (Short_Name, Full_Name) VALUES ('PG', 'Point Guard');
  INSERT INTO POSITION (Short_Name, Full_Name) VALUES ('SG', 'Shooting Guard');
  INSERT INTO POSITION (Short_Name, Full_Name) VALUES ('SF', 'Small Forward');
  INSERT INTO POSITION (Short_Name, Full_Name) VALUES ('PF', 'Power Forward');
  INSERT INTO POSITION (Short_Name, Full_Name) VALUES ('C', 'Center');
  COMMIT;
  
  -- Adding Players
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Abrines, Alex', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Acy, Quincy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Adams, Steven', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Adebayo, Bam', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Afflalo, Arron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ajinca, Alexis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Aldrich, Cole', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Aldridge, LaMarcus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Allen, Jarrett', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Allen, Kadeem', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Aminu, Al-Farouq', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Anderson, Justin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Anderson, Kyle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Anderson, Ryan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Anigbogu, Ike', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Antetokounmpo, Giannis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Anthony, Carmelo', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Anunoby, OG', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Arcidiacono, Ryan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ariza, Trevor', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Arthur, Darrell', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Artis, Jamel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Asik, Omer', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Augustin, D.J.', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Babbitt, Luke', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bacon, Dwayne', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Baker, Ron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Baldwin IV, Wade', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ball, Lonzo', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Barea, J.J.', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Barnes, Harrison', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Barton, Will', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Batum, Nicolas', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bayless, Jerryd', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Baynes, Aron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bazemore, Kent', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Beal, Bradley', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Beasley, Malik', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Beasley, Michael', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Belinelli, Marco', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bell, Jordan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bembry, DeAndre''', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bender, Dragan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bertans, Davis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Beverley, Patrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Birch, Khem', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bird, Jabari', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Biyombo, Bismack', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bjelica, Nemanja', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Black, Tarik', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Blakeney, Antonio', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bledsoe, Eric', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bogdanovic, Bogdan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bogdanovic, Bojan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Booker, Devin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Booker, Trevor', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bradley, Avery', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bradley, Tony', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brewer, Corey', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brogdon, Malcolm', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brooks, Aaron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brooks, Dillon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brooks, MarShon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brown, Anthony', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brown, Jaylen', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brown, Lorenzo', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brown, Markel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Brown, Sterling', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bryant, Thomas', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Bullock, Reggie', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Burke, Trey', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Burks, Alec', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Butler, Jimmy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Buycks, Dwight', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Caboclo, Bruno', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Calderon, Jose', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Caldwell-Pope, Kentavious', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Capela, Clint', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Carroll, DeMarre', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Carter, Vince', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Carter-Williams, Michael', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Caruso, Alex', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cauley-Stein, Willie', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cavanaugh, Tyler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Chalmers, Mario', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Chandler, Tyson', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Chandler, Wilson', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Chriss, Marquese', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Clark, Ian', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Clarkson, Jordan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cleveland, Antonius', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Collins, John', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Collins, Zach', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Collinsworth, Kyle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Collison, Darren', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Collison, Nick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Conley, Mike', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Connaughton, Pat', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cook, Quinn', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cooke, Charles', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cooley, Jack', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Costello, Matt', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cousins, DeMarcus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Covington, Robert', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Crabbe, Allen', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Craig, Torrey', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Crawford, Jamal', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Crawford, Jordan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Crowder, Jae', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Cunningham, Dante', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Curry, Seth', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Curry, Stephen', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Daniels, Troy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Davis, Anthony', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Davis, Deyonta', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Davis, Ed', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('DeRozan, DeMar', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dedmon, Dewayne', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dekker, Sam', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Delaney, Malcolm', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dellavedova, Matthew', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Deng, Luol', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Diallo, Cheick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dieng, Gorgui', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dinwiddie, Spencer', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dorsey, Tyler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dotson, Damyean', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Doyle, Milton', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dozier, PJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dragic, Goran', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Drew II, Larry', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Drummond, Andre', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dudley, Jared', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Dunn, Kris', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Durant, Kevin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Eddie, Jarell', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ellenson, Henry', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ellington, Wayne', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Embiid, Joel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ennis, Tyler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ennis III, James', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Evans, Jawun', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Evans, Jeremy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Evans, Tyreke', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Exum, Dante', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Faried, Kenneth', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Favors, Derrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Felder, Kay', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Felicio, Cristiano', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Felton, Raymond', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ferguson, Terrance', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ferrell, Yogi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Finney-Smith, Dorian', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Forbes, Bryn', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Fournier, Evan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Fox, De''Aaron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Frazier, Tim', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Frye, Channing', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Fultz, Markelle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gallinari, Danilo', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Galloway, Langston', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gasol, Marc', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gasol, Pau', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gay, Rudy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('George, Paul', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Georges-Hunt, Marcus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gibson, Jonathan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gibson, Taj', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Giles III, Harry', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ginobili, Manu', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gobert, Rudy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gordon, Aaron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gordon, Eric', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Gortat, Marcin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Graham, Treveon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Grant, Jerami', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Grant, Jerian', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Green, Danny', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Green, Draymond', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Green, Gerald', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Green, JaMychal', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Green, Jeff', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Griffin, Blake', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hamilton, Daniel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hardaway Jr., Tim', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harden, James', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harkless, Maurice', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harrell, Montrezl', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harris, Devin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harris, Gary', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harris, Joe', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harris, Tobias', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harrison, Aaron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harrison, Andrew', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Harrison, Shaquille', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hart, Josh', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Haslem, Udonis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hayes, Nigel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hayward, Gordon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hearn, Reggie', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Henry, Myke', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Henson, John', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hernangomez, Juancho', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hernangomez, Willy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hezonja, Mario', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hicks, Isaiah', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hield, Buddy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hill, George', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hill, Solomon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hilliard, Darrun', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Holiday, Jrue', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Holiday, Justin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hollis-Jefferson, Rondae', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Holmes, Richaun', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hood, Rodney', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Horford, Al', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('House, Danuel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Howard, Dwight', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Huestis, Josh', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Hunter, RJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ibaka, Serge', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Iguodala, Andre', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ilyasova, Ersan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ingles, Joe', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ingram, Andre', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ingram, Brandon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Irving, Kyrie', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Isaac, Jonathan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Iwundu, Wes', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jack, Jarrett', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jackson, Aaron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jackson, Demetrius', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jackson, Frank', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jackson, Josh', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jackson, Justin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jackson, Reggie', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('James, LeBron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jefferson, Al', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jefferson, Amile', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jefferson, Richard', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jennings, Brandon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jerebko, Jonas', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Johnson, Amir', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Johnson, Dakari', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Johnson, James', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Johnson, Joe', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Johnson, Stanley', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Johnson, Tyler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Johnson, Wesley', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jokic, Nikola', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jones, Damian', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jones, Jalen', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jones, Tyus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jones Jr., Derrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Jordan, DeAndre', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Joseph, Cory', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kaminsky, Frank', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kanter, Enes', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kennard, Luke', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kidd-Gilchrist, Michael', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kilpatrick, Sean', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kleber, Maxi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Knight, Brandon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Korkmaz, Furkan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kornet, Luke', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Korver, Kyle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Koufos, Kosta', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Kuzma, Kyle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('LaVine, Zach', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Labissiere, Skal', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lamb, Jeremy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Larkin, Shane', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lauvergne, Joffrey', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lawson, Ty', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Layman, Jake', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('LeVert, Caris', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Leaf, TJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lee, Courtney', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lee, Damion', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Len, Alex', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Leonard, Kawhi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Leonard, Meyers', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Leuer, Jon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Liggins, DeAndre', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lillard, Damian', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lin, Jeremy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Livingston, Shaun', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Looney, Kevon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lopez, Brook', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lopez, Robin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Love, Kevin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lowry, Kyle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Luwawu-Cabarrot, Timothe', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lydon, Tyler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Lyles, Trey', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Magette, Josh', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mahinmi, Ian', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Maker, Thon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Marjanovic, Boban', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Markkanen, Lauri', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Martin, Jarell', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mason, Frank', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mathiang, Mangok', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Matthews, Wesley', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mbah a Moute, Luc', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McCaw, Patrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McCollum, CJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McConnell, T.J.', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McCree, Erik', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McCullough, Chris', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McDermott, Doug', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McGee, JaVale', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McGruder, Rodney', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McKinnie, Alfonzo', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('McLemore, Ben', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Meeks, Jodie', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mejri, Salah', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mickey, Jordan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Middleton, Khris', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Miles, CJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Miller, Darius', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Miller, Malcolm', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mills, Patty', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Millsap, Paul', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mirotic, Nikola', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mitchell, Donovan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Monk, Malik', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Monroe, Greg', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Moore, Ben', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Moore, E''Twaun', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Moreland, Eric', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Morris, Jaylen', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Morris, Marcus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Morris, Markieff', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Morris, Monte', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Motley, Johnathan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mozgov, Timofey', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Mudiay, Emmanuel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Muhammad, Shabazz', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Munford, Xavier', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Murray, Dejounte', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Murray, Jamal', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Muscala, Mike', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nene', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nader, Abdel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nance Jr., Larry', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Napier, Shabazz', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nelson, Jameer', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Neto, Raul', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Niang, Georges', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Noah, Joakim', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Noel, Nerlens', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nogueira, Lucas', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nowitzki, Dirk', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ntilikina, Frank', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nurkic, Jusuf', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Nwaba, David', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('O''Neale, Royce', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('O''Quinn, Kyle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ojeleye, Semi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Okafor, Emeka', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Okafor, Jahlil', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Oladipo, Victor', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Olynyk, Kelly', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Onuaku, Chinanu', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Osman, Cedi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Oubre Jr., Kelly', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Pachulia, Zaza', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Paige, Marcus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Papagiannis, Georgios', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Parker, Jabari', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Parker, Tony', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Parsons, Chandler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Patterson, Patrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Patton, Justin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Paul, Brandon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Paul, Chris', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Payne, Cameron', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Payton, Elfrid', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Payton II, Gary', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Perkins, Kendrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Peters, Alec', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Plumlee, Marshall', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Plumlee, Mason', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Plumlee, Miles', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Poeltl, Jakob', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Porter Jr., Otto', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Portis, Bobby', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Porzingis, Kristaps', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Powell, Dwight', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Powell, Norman', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Poythress, Alex', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Prince, Taurean', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Purvis, Rodney', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Rabb, Ivan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Randle, Julius', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Randolph, Zach', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Redick, JJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Reed, Davon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Richardson, Josh', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Richardson, Malachi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Rivers, Austin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Roberson, Andre', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Robinson, Devin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Robinson III, Glenn', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Rondo, Rajon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Rose, Derrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ross, Terrence', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Rozier, Terry', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Rubio, Ricky', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Russell, D''Angelo', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Sabonis, Domantas', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Sampson, JaKarr', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Saric, Dario', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Satoransky, Tomas', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Schroder, Dennis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Scott, Mike', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Sefolosha, Thabo', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Selden, Wayne', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Sessions, Ramon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Shumpert, Iman', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Siakam, Pascal', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Silas, Xavier', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Simmons, Ben', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Simmons, Jonathon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Simmons, Kobi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Singler, Kyle', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Smart, Marcus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Smith, Ish', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Smith, JR', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Smith, Jason', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Smith Jr., Dennis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Snell, Tony', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Speights, Marreese', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Stauskas, Nik', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Stephenson, Lance', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Stockton, David', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Stone, Julyan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Sumner, Edmond', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Swanigan, Caleb', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Tatum, Jayson', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Taylor, Isaiah', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Teague, Jeff', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Teague, Marquis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Temple, Garrett', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Teodosic, Milos', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Terry, Jason', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Theis, Daniel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Thomas, Isaiah', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Thomas, Lance', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Thompson, Klay', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Thompson, Tristan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Thornwell, Sindarius', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Tolliver, Anthony', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Towns, Karl-Anthony', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Tucker, PJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Turner, Evan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Turner, Myles', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Udoh, Ekpe', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Ulis, Tyler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Valanciunas, Jonas', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Valentine, Denzel', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('VanVleet, Fred', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Vonleh, Noah', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Vucevic, Nikola', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wade, Dwyane', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Waiters, Dion', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Walker, Kemba', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wall, John', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wallace, Tyrone', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Walton Jr., Derrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Warren, TJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wear, Travis', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Webb III, James', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Weber, Briante', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('West, David', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Westbrook, Russell', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('White, Derrick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('White, Okaro', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('White III, Andrew', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Whitehead, Isaiah', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Whiteside, Hassan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wiggins, Andrew', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wilcox, CJ', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Williams, Alan', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Williams, C.J.', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Williams, Lou', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Williams, Marvin', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Williams, Troy', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wilson, D.J.', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Winslow, Justise', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Wright, Delon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Yabusele, Guerschon', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Young, Joe', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Young, Nick', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Young, Thaddeus', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Zhou Qi', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Zeller, Cody', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Zeller, Tyler', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Zipser, Paul', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Zizic, Ante', 0);
  INSERT INTO PLAYER (Name, Is_Injured) VALUES ('Zubac, Ivica', 0);
  COMMIT;
  
  -- Adding Clubs
  INSERT INTO CLUB (Name) VALUES('Houston Rockets');
  INSERT INTO CLUB (Name) VALUES('Toronto Raptors');
  INSERT INTO CLUB (Name) VALUES('Golden State Warriors');
  INSERT INTO CLUB (Name) VALUES('Boston Celtics');
  INSERT INTO CLUB (Name) VALUES('Philadelphia 76ers');
  INSERT INTO CLUB (Name) VALUES('Cleveland Cavaliers');
  INSERT INTO CLUB (Name) VALUES('Portland Trail Blazers');
  INSERT INTO CLUB (Name) VALUES('Indiana Pacers');
  INSERT INTO CLUB (Name) VALUES('Oklahoma City Thunder');
  INSERT INTO CLUB (Name) VALUES('New Orleans Pelicans');
  INSERT INTO CLUB (Name) VALUES('Utah Jazz');
  INSERT INTO CLUB (Name) VALUES('San Antonio Spurs');
  INSERT INTO CLUB (Name) VALUES('Minnesota Timberwolves');
  INSERT INTO CLUB (Name) VALUES('Denver Nuggets');
  INSERT INTO CLUB (Name) VALUES('Miami Heat');
  INSERT INTO CLUB (Name) VALUES('Milwaukee Bucks');
  INSERT INTO CLUB (Name) VALUES('Washington Wizards');
  INSERT INTO CLUB (Name) VALUES('LA Clippers');
  INSERT INTO CLUB (Name) VALUES('Detroit Pistons');
  INSERT INTO CLUB (Name) VALUES('Charlotte Hornets');
  INSERT INTO CLUB (Name) VALUES('Los Angeles Lakers');
  INSERT INTO CLUB (Name) VALUES('New York Knicks');
  INSERT INTO CLUB (Name) VALUES('Brooklyn Nets');
  INSERT INTO CLUB (Name) VALUES('Sacramento Kings');
  INSERT INTO CLUB (Name) VALUES('Chicago Bulls');
  INSERT INTO CLUB (Name) VALUES('Orlando Magic');
  INSERT INTO CLUB (Name) VALUES('Dallas Mavericks');
  INSERT INTO CLUB (Name) VALUES('Atlanta Hawks');
  INSERT INTO CLUB (Name) VALUES('Memphis Grizzlies');
  INSERT INTO CLUB (Name) VALUES('Phoenix Suns');
  COMMIT;
  
  -- Adding Leagues
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('ABA', 'American Basketball Association');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('APBL', 'American Professional Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('CBA', 'Central Basketball Association');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('ECBL', 'East Coast Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('FBA', 'Florida Basketball Association');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('IBA', 'Independent Basketball Association');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('JBA', 'Junior Basketball Association');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('MBL', 'Midwest Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('MPBA', 'Midwest Professional Basketball Association');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('NABL', 'North American Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('PBL', 'Premier Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('TBL', 'The Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('TRBL', 'Tobacco Road Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('UBL', 'United Basketball League');
  INSERT INTO LEAGUE (Short_Name, Full_Name) VALUES ('UBA', 'Universal Basketball Association');
  COMMIT;
  
  --Adding Season
  INSERT INTO SEASON (Year, Date_Start, Date_End) VALUES (2019, to_date('01.10.2018','dd.mm.yyyy'), to_date('30.04.2019','dd.mm.yyyy'));
  INSERT INTO SEASON (Year, Date_Start, Date_End) VALUES (2020, to_date('01.10.2019','dd.mm.yyyy'), to_date('30.04.2020','dd.mm.yyyy'));
  INSERT INTO SEASON (Year, Date_Start, Date_End, Team_Size) VALUES (2021, to_date('01.10.2020','dd.mm.yyyy'), to_date('30.04.2021','dd.mm.yyyy'), 17);
  INSERT INTO SEASON (Year, Date_Start, Date_End) VALUES (2022, to_date('01.10.2021','dd.mm.yyyy'), to_date('30.04.2022','dd.mm.yyyy'));
  INSERT INTO SEASON (Year, Date_Start, Date_End) VALUES (2023, to_date('01.10.2022','dd.mm.yyyy'), to_date('30.04.2023','dd.mm.yyyy'));
  COMMIT;
  
END INIT_DATA;

/
--------------------------------------------------------
--  DDL for Procedure INIT_RELATIONS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE INIT_RELATIONS AS 
  pos_amt NUMBER(8, 0);
  assoc_amt NUMBER(8, 0);
  league_num NUMBER(8, 0);
  player_num NUMBER(8, 0);
BEGIN

  -- Assigning Positions for each Player
  FOR c IN (SELECT id FROM PLAYER)
  LOOP
    pos_amt := dbms_random.value(1, 5);
    INSERT INTO PLAYER_POSITION_REL(
    SELECT c.id as player_id,
           position_id
      FROM (
            SELECT trunc(dbms_random.random()) as rand,
                   p.id as position_id
              FROM POSITION p
             ORDER BY rand
             FETCH FIRST pos_amt ROW ONLY
           )
    );
  END LOOP;
  COMMIT;

  -- Assigning Budget for each League
  INSERT INTO BUDGET (
                      SELECT l.id as league_id,
                             s.id as season_id,
                             trunc(dbms_random.value(40, 70)) * 1000000 as amount
                       FROM  SEASON s,
                             LEAGUE l
                     );
  COMMIT;

  -- Assigning Clubs to the Leagues--  
  FOR c IN (SELECT id, name FROM CLUB)
  LOOP
    -- Choosing League for the Club
    league_num := dbms_random.value(1, 8);
    
    INSERT INTO LEAGUE_SEASON_CLUB_REL (
    SELECT s.id as season_id,
           t.id as league_id,
           c.id as club_id
      FROM (
            SELECT rownum as nn,
                   l.*
              FROM LEAGUE l
             WHERE full_name LIKE '%League'
           ) t,
           SEASON s
     WHERE t.nn = league_num
    ); 
    
    -- Choosing several Associations for the Club
    assoc_amt := dbms_random.value(1, 3);
    
    INSERT INTO LEAGUE_SEASON_CLUB_REL (
    SELECT s.id as season_id,
           t.id as league_id,
           c.id as club_id
      FROM (
            SELECT rownum as nn,
                   trunc(dbms_random.value(1, 7)) as rand,
                   l.*
              FROM LEAGUE l
             WHERE full_name LIKE '%Association'
             ORDER BY rand
             FETCH FIRST assoc_amt ROW ONLY
           ) t,
           SEASON s
    );
 
  END LOOP;
  COMMIT;
  
  -- Form the teams for 2019 Season
  FOR c IN (SELECT id, name FROM CLUB)
  LOOP
    player_num := dbms_random.value(11, 15);
    INSERT INTO CONTRACT (club_id, player_id, date_start, date_end, value) 
    (
    SELECT c.id,
           player_id,
           sysdate,--date_start,
           date_end,
           value
      FROM (
            SELECT rownum as nn,
                   trunc(dbms_random.random()) as rand,
                   s.date_start,
                   s.date_end,
                   trunc(dbms_random.value(50, 900))*10000 as value,
                   p.id as player_id
              FROM PLAYER p,
                   SEASON s
             WHERE s.year = 2019
               AND NOT EXISTS (SELECT id FROM CONTRACT c WHERE c.player_id = p.id) 
             ORDER BY rand
             FETCH FIRST player_num ROW ONLY
           )
     );
     COMMIT;
  END LOOP;
  
END INIT_RELATIONS;

/


-- Initializing schema with test data
BEGIN
   INITIALIZE;
END;

/

CREATE OR REPLACE DIRECTORY backup_dir AS '/home/oracle/backup';

/
