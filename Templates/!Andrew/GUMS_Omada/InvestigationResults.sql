/*
Fehlende Indexdetails von ExecutionPlan2.sqlplan
Der Abfrageprozessor schätzt, dass durch das Implementieren des folgenden Indexes die Abfragekosten um 64.3955 % verbessert werden können.
*/

/*
USE [Omada Data Warehouse]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[ResourceAssignmentFact] ([IsRowLatest])
INCLUDE ([ResourceKey],[SystemKey],[IdentityKey],[ResourceAssignmentKey],[ODWSourceSystemKey])
GO
*/

(@state int,@targetid int,@absduration int,@duration int,@processid int)update tblProcess set _STATE=@state, _TARGETID=@targetid, _ABSDURATION=@absduration, _DURATION=@duration 
where _ID=@processid and (_TARGETID is null or _DELETETIME is null)

SELECT        this_.Id AS Id27352_0_, this_.UpdatedTime AS UpdatedT2_27352_0_, this_.DisplayName AS DisplayN3_27352_0_, this_.Status AS Status27352_0_, 
                         this_.ClosedReason AS ClosedRe5_27352_0_, this_.NotificationText AS Notifica6_27352_0_, this_.StartDate AS StartDate27352_0_, 
                         this_.DueDate AS DueDate27352_0_, this_.ClosedDate AS ClosedDate27352_0_, this_.EscalationInDays AS Escalat10_27352_0_, 
                         this_.Escalated AS Escalated27352_0_, this_.AttestOnlyNotPreviouslyAttested AS AttestO12_27352_0_, this_.AttestOnlyBeforePeriod AS AttestO13_27352_0_, 
                         this_.AttestOnlyBeforePeriodUnit AS AttestO14_27352_0_, this_.IncludeChildContexts AS Include15_27352_0_, this_.DirectlyAssignedFilter AS Directl16_27352_0_, 
                         this_.AccountTypeFilter AS Account17_27352_0_, this_.IncludePreviouslyAnsweredWith AS Include18_27352_0_, this_.RecurringSurveyId AS Recurri19_27352_0_, 
                         this_.EndlessRecurring AS Endless20_27352_0_, this_.RecurringPeriod AS Recurri21_27352_0_, this_.RecurringPeriodUnit AS Recurri22_27352_0_, 
                         this_.RecurringPermissionDeltaPeriod AS Recurri23_27352_0_, this_.RecurringPermissionDeltaPeriodUnit AS Recurri24_27352_0_, 
                         this_.AnswerResponsibleType AS AnswerR25_27352_0_, this_.AutocloseInDays AS Autoclo26_27352_0_, this_.ContextId AS ContextId27352_0_, 
                         this_.CreatedBy AS CreatedBy27352_0_, this_.NextRecurringSurvey AS NextRec29_27352_0_, this_.ResponsibleId AS Respons30_27352_0_, 
                         this_.AnswerResponsibleId AS AnswerR31_27352_0_, this_.SurveyTypeId AS SurveyT32_27352_0_, CASE WHEN this_1_.SurveyId IS NOT NULL 
                         THEN 1 WHEN this_2_.SurveyId IS NOT NULL THEN 2 WHEN this_3_.SurveyId IS NOT NULL THEN 3 WHEN this_4_.SurveyId IS NOT NULL 
                         THEN 4 WHEN this_5_.SurveyId IS NOT NULL THEN 5 WHEN this_.Id IS NOT NULL THEN 0 END AS clazz_0_
FROM            Surveys AS this_ LEFT OUTER JOIN
                         PermissionSurveys AS this_1_ ON this_.Id = this_1_.SurveyId LEFT OUTER JOIN
                         SodSurveys AS this_2_ ON this_.Id = this_2_.SurveyId LEFT OUTER JOIN
                         AccountSurveys AS this_3_ ON this_.Id = this_3_.SurveyId LEFT OUTER JOIN
                         GroupSurveys AS this_4_ ON this_.Id = this_4_.SurveyId LEFT OUTER JOIN
                         PermissionEntitlementSurveys AS this_5_ ON this_.Id = this_5_.SurveyId