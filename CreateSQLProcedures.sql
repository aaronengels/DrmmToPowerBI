IF OBJECT_ID ('drmm.insertSite') IS NOT NULL
    DROP PROCEDURE drmm.insertSite
GO

CREATE PROCEDURE drmm.insertSite
    @json NVARCHAR(MAX)
AS
	 INSERT INTO temp.sites
	 SELECT
	 	[id],
		[uid],
		[name], 
		[description], 
		[ondemand], 
		[deleted] = 0,
		[autotaskName], 
		[autotaskId], 
		[portalUrl],
		GETDATE() AS [lastUpdate]
	FROM OPENJSON(@json)
	 WITH (   
		[id] INT                    '$.id',
		[uid] CHAR(36)              '$.uid',
		[name] VARCHAR(MAX)         '$.name',
		[description] VARCHAR(MAX)  '$.description',
		[ondemand] BIT              '$.onDemand',
		[autotaskName] VARCHAR(MAX) '$.autotaskCompanyName',
		[autotaskId] INT            '$.autotaskCompanyId',
		[portalUrl] VARCHAR(MAX)    '$.portalUrl'
	 );
GO

IF OBJECT_ID ('drmm.mergeSites') IS NOT NULL
    DROP PROCEDURE drmm.mergeSites
GO

CREATE PROCEDURE drmm.mergeSites
AS
	MERGE drmm.sites AS target
	USING temp.sites AS source 
	ON (target.[id] = source.[id])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[uid] = source.[uid],
			target.[name] = source.[name],
			target.[description] = source.[description],
			target.[ondemand] = source.[ondemand],
			target.[deleted] = source.[deleted],
			target.[autotaskName] = source.[autotaskName],
			target.[autotaskId] = source.[autotaskId],
			target.[portalUrl] = source.[portalUrl],
			target.[lastUpdate] = source.[lastUpdate]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
	 		[id],
			[uid],
			[name], 
			[description], 
			[ondemand], 
			[deleted],
			[autotaskName], 
			[autotaskId], 
			[portalUrl],
			[lastUpdate]
		)
		VALUES (
			source.[id],
			source.[uid],
			source.[name], 
			source.[description], 
			source.[ondemand],
			source.[deleted],
			source.[autotaskName], 
			source.[autotaskId], 
			source.[portalUrl],
			source.[lastUpdate]
		)
	WHEN NOT MATCHED BY SOURCE THEN
		UPDATE SET
			target.[deleted] = 1,
			target.[lastUpdate] = GETDATE();
GO

IF OBJECT_ID ('drmm.insertDevice') IS NOT NULL
    DROP PROCEDURE drmm.insertDevice
GO

CREATE PROCEDURE drmm.insertDevice
	@json NVARCHAR(MAX)
AS
	INSERT INTO temp.devices
	SELECT
		[id],
		[uid],
		[siteId],
		[name],
		[description],
		[deviceType],
		[deviceClass],
		[dotNetVersion],
		[manufacturer],
		[model],
		[serialnumber],
		[cpuCores],
		[memoryBig]/1024/1024 AS [memory],
		[domain],
		[username],
		[lastSeenUser],
		[ipaddress],
		[os],
		[is64bit],
		[snmpEnabled],
		[suspended],
		[deleted],
		[rebootRequired],
		DATEADD(s, CAST(ROUND([warrantyDateEpoch] / 1000,0) AS INT), '1970-01-01') AS [warrantyDate],
		DATEADD(s, CAST(ROUND([lastAuditEpoch] / 1000,0) AS INT), '1970-01-01') AS [lastAudit],
		DATEADD(s, CAST(ROUND([lastRebootEpoch] / 1000,0) AS INT), '1970-01-01') AS [lastReboot],
		DATEADD(s, CAST(ROUND([lastSeenEpoch] / 1000,0) AS INT), '1970-01-01') AS [lastSeen],
		GETDATE() AS [lastUpdate]
	FROM OPENJSON(@json)
	WITH (   
		[id] INT						'$.id',
		[uid] CHAR(36)					'$.uid',
		[siteId] INT					'$.siteId',
		[name] VARCHAR(MAX)				'$.hostname',
		[description] VARCHAR(MAX)		'$.description',
		[deviceType] VARCHAR(MAX)		'$.deviceType.category',
		[deviceClass] VARCHAR(MAX)		'$.deviceClass',
		[dotNetVersion] VARCHAR(MAX)	'$.systemInfo.dotNetVersion',
		[manufacturer] VARCHAR(MAX)		'$.systemInfo.manufacturer',
		[model] VARCHAR(MAX)			'$.systemInfo.model',
		[serialnumber] VARCHAR(MAX)		'$.bios.serialNumber',
		[cpuCores] INT					'$.systemInfo.totalCpuCores',
		[memoryBig] BIGINT				'$.systemInfo.totalPhysicalMemory',
		[domain] VARCHAR(MAX)			'$.domain',
		[username] VARCHAR(MAX)			'$.systemInfo.username',
		[lastSeenUser] VARCHAR(MAX)		'$.lastLoggedInUser',
		[ipaddress] VARCHAR(MAX)		'$.intIpAddress',
		[os] VARCHAR(MAX)				'$.operatingSystem',
		[is64bit] BIT					'$.a64Bit',
		[snmpEnabled] BIT				'$.snmpEnabled',
		[suspended] BIT					'$.suspended',
		[deleted] BIT					'$.deleted',
		[rebootRequired] BIT			'$.rebootRequired',
		[warrantyDateEpoch] BIGINT		'$.warrantyDate',
		[lastAuditEpoch] BIGINT			'$.lastAuditDate',
		[lastRebootEpoch] BIGINT		'$.lastReboot',
		[lastSeenEpoch] BIGINT			'$.lastSeen'
	);
GO

IF OBJECT_ID ('drmm.mergeDevices') IS NOT NULL
    DROP PROCEDURE drmm.mergeDevices
GO

CREATE PROCEDURE [drmm].[mergeDevices]
AS
	MERGE drmm.devices AS target
	USING temp.devices AS source 
	ON (target.[id] = source.[id])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[uid] = source.[uid],
			target.[siteId] = source.[siteId],
			target.[name] = source.[name],
			target.[description] = source.[description],
			target.[deviceType] = source.[deviceType],
			target.[deviceClass] = source.[deviceClass],
			target.[dotNetVersion] = source.[dotNetVersion],
			target.[manufacturer] = source.[manufacturer],
			target.[model] = source.[model],
			target.[serialnumber] = source.[serialnumber],
			target.[cpuCores] = source.[cpuCores],
			target.[memory] = source.[memory],
			target.[domain] = source.[domain],
			target.[username] = source.[username],
			target.[lastSeenUser] = source.[lastSeenUser],
			target.[ipaddress] = source.[ipaddress],
			target.[os] = source.[os],
			target.[is64bit] = source.[is64bit],
			target.[snmpEnabled] = source.[snmpEnabled],
			target.[suspended] = source.[suspended],
			target.[deleted] = source.[deleted],
			target.[rebootRequired] = source.[rebootRequired],
			target.[warrantyDate] = source.[warrantyDate],
			target.[lastAudit] = source.[lastAudit],
			target.[lastReboot] = source.[lastReboot],
			target.[lastSeen] = source.[lastSeen],
			target.[lastUpdate] = source.[lastUpdate]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[id],
			[uid],
			[siteId],
			[name],
			[description],
			[deviceType],
			[deviceClass],
			[dotNetVersion],
			[manufacturer],
			[model],
			[serialnumber],
			[cpuCores],
			[memory],
			[domain],
			[username],
			[lastSeenUser],
			[ipaddress],
			[os],
			[is64bit],
			[snmpEnabled],
			[suspended],
			[deleted],
			[rebootRequired],
			[warrantyDate],
			[lastAudit],
			[lastReboot],
			[lastSeen],
			[lastupdate]
		)
		VALUES (
			source.[id],
			source.[uid],
			source.[siteId],
			source.[name],
			source.[description],
			source.[deviceType],
			source.[deviceClass],
			source.[dotNetVersion],
			source.[manufacturer],
			source.[model],
			source.[serialnumber],
			source.[cpuCores],
			source.[memory],
			source.[domain],
			source.[username],
			source.[lastSeenUser],
			source.[ipaddress],
			source.[os],
			source.[is64bit],
			source.[snmpEnabled],
			source.[suspended],
			source.[deleted],
			source.[rebootRequired],
			source.[warrantyDate],
			source.[lastAudit],
			source.[lastReboot],
			source.[lastSeen],
			source.[lastupdate]
		)
	WHEN NOT MATCHED BY SOURCE THEN
		UPDATE SET
			target.[deleted] = 1,
			target.[lastUpdate] = GETDATE();
GO

IF OBJECT_ID ('drmm.insertAlert') IS NOT NULL
    DROP PROCEDURE drmm.insertAlert
GO

CREATE PROCEDURE drmm.insertAlert
    @json NVARCHAR(MAX)
AS
	 INSERT INTO temp.alerts
	 SELECT
		[uid],
		[deviceId],
		[type],
		[message],
		[diagnostic],
		[priority],
		[ticketId],
		[muted],
		[resolved],
		[resolvedBy],
		DATEADD(s, CAST(ROUND([resolvedOnEpoch] / 1000,0) AS INT), '1970-01-01') AS [resolvedOn],
		DATEADD(s, CAST(ROUND([timestampEpoch] / 1000,0) AS INT), '1970-01-01') AS [timestamp]
	FROM OPENJSON(@json)
	 WITH (   
		[uid] CHAR(36)				'$.alertUid',
		[deviceId] INT				'$.deviceId',
		[type] VARCHAR(MAX)			'$.alertType',
		[message] VARCHAR(MAX)		'$.alertMessage',
		[diagnostic] VARCHAR(MAX)	'$.diagnostics',
		[priority] VARCHAR(MAX)		'$.priority',
		[ticketId] VARCHAR(MAX)		'$.ticketNumber',
		[muted] BIT					'$.muted',
		[resolved] BIT				'$.resolved',
		[resolvedBy] VARCHAR(MAX)	'$.resolvedBy',
		[resolvedOnEpoch] BIGINT	'$.resolvedon',
		[timestampEpoch] BIGINT		'$.timestamp'
	 );
GO

IF OBJECT_ID ('drmm.mergeAlerts') IS NOT NULL
    DROP PROCEDURE drmm.mergeAlerts
GO

CREATE PROCEDURE [drmm].[mergeAlerts]
AS
	MERGE drmm.alerts AS target
	USING temp.alerts AS source 
	ON (target.[uid] = source.[uid])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[uid] = source.[uid],
			target.[deviceId] = source.[deviceId],
			target.[type] = source.[type],
			target.[message] = source.[message],
			target.[diagnostic] = source.[diagnostic],
			target.[priority] = source.[priority],
			target.[ticketId] = source.[ticketId],
			target.[muted] = source.[muted],
			target.[resolved] = source.[resolved],
			target.[resolvedBy] = source.[resolvedBy],
			target.[resolvedOn] = source.[resolvedOn],
			target.[timestamp] = source.[timestamp]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[uid],
			[deviceId],
			[type],
			[message],
			[diagnostic],
			[priority],
			[ticketId],
			[muted],
			[resolved],
			[resolvedBy],
			[resolvedOn],
			[timestamp]
		)
		VALUES (
			source.[uid],
			source.[deviceId],
			source.[type],
			source.[message],
			source.[diagnostic],
			source.[priority],
			source.[ticketId],
			source.[muted],
			source.[resolved],
			source.[resolvedBy],
			source.[resolvedOn],
			source.[timestamp]
		)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
GO

IF OBJECT_ID ('drmm.insertPatchStatus') IS NOT NULL
    DROP PROCEDURE drmm.insertPatchStatus
GO

CREATE PROCEDURE drmm.insertPatchStatus
    @json NVARCHAR(MAX)
AS
	 INSERT INTO temp.patchstatus
	 SELECT
		[deviceId],
		[status],
		[notApproved],
		[approvedPending],
		[installed],
		GETDATE() AS [timestamp] 
	FROM OPENJSON(@json)
	 WITH (   
		[deviceId] INT					'$.id',
		[status] VARCHAR(MAX)			'$.patchManagement.patchStatus',
		[notApproved] VARCHAR(MAX)		'$.patchManagement.patchesNotApproved',
		[approvedPending] VARCHAR(MAX)	'$.patchManagement.patchesApprovedPending',
		[installed] VARCHAR(MAX)		'$.patchManagement.patchesInstalled'
	 );

GO

IF OBJECT_ID ('drmm.mergePatchStatus') IS NOT NULL
    DROP PROCEDURE drmm.mergePatchStatus
GO

CREATE PROCEDURE drmm.mergePatchStatus
AS
	MERGE drmm.patchstatus AS target
	USING temp.patchstatus AS source 
	ON (target.[timestamp] = source.[timestamp])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[deviceId] = source.[deviceId],
			target.[status] = source.[status],
			target.[notApproved] = source.[notApproved],
			target.[approvedPending] = source.[approvedPending],
			target.[installed] = source.[installed],
			target.[timestamp] = source.[timestamp]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[deviceId],
			[status],
			[notApproved],
			[approvedPending],
			[installed],
			[timestamp] 
		)
		VALUES (
			source.[deviceId],
			source.[status],
			source.[notApproved],
			source.[approvedPending],
			source.[installed],
			source.[timestamp]
		);
GO

IF OBJECT_ID ('drmm.insertThirdPartyStatus') IS NOT NULL
    DROP PROCEDURE drmm.insertThirdPartyStatus
GO

CREATE PROCEDURE drmm.insertThirdPartyStatus
    @json NVARCHAR(MAX)
AS
	 INSERT INTO temp.thirdpartystatus
	 SELECT
		[deviceId],
		[status],
		GETDATE() AS [timestamp] 
	 FROM OPENJSON(@json)
	 WITH (   
		[deviceId] INT				'$.id',
		[status] VARCHAR(MAX)		'$.softwareStatus'
	 );
GO

IF OBJECT_ID ('drmm.mergeThirdPartyStatus') IS NOT NULL
    DROP PROCEDURE drmm.mergeThirdPartyStatus
GO

CREATE PROCEDURE drmm.mergeThirdPartyStatus
AS
	MERGE drmm.thirdpartyStatus AS target
	USING temp.thirdpartyStatus AS source 
	ON (target.[timestamp] = source.[timestamp])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[deviceId] = source.[deviceId],
			target.[status] = source.[status],
			target.[timestamp] = source.[timestamp]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[deviceId],
			[status],
			[timestamp] 
		)
		VALUES (
			source.[deviceId],
			source.[status],
			source.[timestamp]
		);
GO


IF OBJECT_ID ('drmm.insertAvStatus') IS NOT NULL
    DROP PROCEDURE drmm.insertAvStatus
GO

CREATE PROCEDURE drmm.insertAvStatus
    @json NVARCHAR(MAX)
AS
	INSERT INTO temp.avstatus
	SELECT
		[deviceId],
		[product],
		[status],
		GETDATE() AS [timestamp] 
	FROM OPENJSON(@json)
	WITH (   
		[deviceId] INT				'$.id',
		[product] VARCHAR(MAX)		'$.antivirus.antivirusProduct',
		[status] VARCHAR(MAX)		'$.antivirus.antivirusStatus'
	 );
GO

IF OBJECT_ID ('drmm.mergeAvStatus') IS NOT NULL
    DROP PROCEDURE drmm.mergeAvStatus
GO

CREATE PROCEDURE drmm.mergeAvStatus
AS
	MERGE drmm.avstatus AS target
	USING temp.avstatus AS source 
	ON (target.[timestamp] = source.[timestamp])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[deviceId] = source.[deviceId],
			target.[product] = source.[product],
			target.[status] = source.[status],
			target.[timestamp] = source.[timestamp]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[deviceId],
			[product],
			[status],
			[timestamp] 
		)
		VALUES (
			source.[deviceId],
			source.[product],
			source.[status],
			source.[timestamp]
		);
GO


IF OBJECT_ID ('drmm.insertAgentStatus') IS NOT NULL
    DROP PROCEDURE drmm.insertAgentStatus
GO

CREATE PROCEDURE drmm.insertAgentStatus
    @json NVARCHAR(MAX)
AS
	INSERT INTO temp.agentstatus
	SELECT
		[deviceId],
		[online],
		GETDATE() AS [timestamp] 
	FROM OPENJSON(@json)
	WITH (   
		[deviceId] INT				'$.id',
		[online] BIT				'$.online'
	 );
GO

IF OBJECT_ID ('drmm.mergeAgentStatus') IS NOT NULL
    DROP PROCEDURE drmm.mergeAgentStatus
GO

CREATE PROCEDURE drmm.mergeAgentStatus
AS
	MERGE drmm.agentstatus AS target
	USING temp.agentstatus AS source 
	ON (target.[timestamp] = source.[timestamp])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[deviceId] = source.[deviceId],
			target.[online] = source.[online],
			target.[timestamp] = source.[timestamp]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[deviceId],
			[online],
			[timestamp] 
		)
		VALUES (
			source.[deviceId],
			source.[online],
			source.[timestamp]
		);
GO


IF OBJECT_ID ('drmm.insertDiskStatus') IS NOT NULL
    DROP PROCEDURE drmm.insertDiskStatus
GO

CREATE PROCEDURE drmm.insertDiskStatus
    @json NVARCHAR(MAX)
AS
	 INSERT INTO temp.diskstatus
	 SELECT
		[deviceId],
		[description],
		[identifier],
		[sizeBig]/1024/1024 AS [size],
		[freespaceBig]/1024/1024 AS [freespace],
		GETDATE() AS [timestamp] 
	FROM OPENJSON(@json)
	 WITH (   
		[deviceId] INT				'$.deviceId',
		[description] VARCHAR(MAX)	'$.description',
		[identifier] VARCHAR(MAX)	'$.diskIdentifier',
		[sizeBig] BIGINT			'$.freespace',
		[freespaceBig] BIGINT		'$.size'
	 );
GO

IF OBJECT_ID ('drmm.mergeDiskStatus') IS NOT NULL
    DROP PROCEDURE drmm.mergeDiskStatus
GO

CREATE PROCEDURE drmm.mergeDiskStatus
AS
	MERGE drmm.diskstatus AS target
	USING temp.diskstatus AS source 
	ON (target.[timestamp] = source.[timestamp])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[deviceId] = source.[deviceId],
			target.[description] = source.[description],
			target.[identifier] = source.[identifier],
			target.[size] = source.[size],
			target.[freespace] = source.[freespace],
			target.[timestamp] = source.[timestamp]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[deviceId],
			[description],
			[identifier],
			[size],
			[freespace],
			[timestamp] 
		)
		VALUES (
			source.[deviceId],
			source.[description],
			source.[identifier],
			source.[size],
			source.[freespace],
			source.[timestamp]
		);
GO


IF OBJECT_ID ('drmm.insertUdfs') IS NOT NULL
    DROP PROCEDURE drmm.insertUdfs
GO

CREATE PROCEDURE drmm.insertUdfs
    @json NVARCHAR(MAX)
AS
	 INSERT INTO temp.udfs
	 SELECT
		[deviceId],
		[udf1],
		[udf2],
		[udf3],
		[udf4],
		[udf5],
		[udf6],
		[udf7],
		[udf8],
		[udf9],
		[udf10],
		[udf11],
		[udf12],
		[udf13],
		[udf14],
		[udf15],
		[udf16],
		[udf17],
		[udf18],
		[udf19],
		[udf20],
		[udf21],
		[udf22],
		[udf23],
		[udf24],
		[udf25],
		[udf26],
		[udf27],
		[udf28],
		[udf29],
		[udf30],
		GETDATE() AS [timestamp] 
	FROM OPENJSON(@json)
	 WITH (   
		[deviceId] INT			'$.id',
		[udf1] VARCHAR(MAX)		'$.udf.udf1',
		[udf2] VARCHAR(MAX)		'$.udf.udf2',
		[udf3] VARCHAR(MAX)		'$.udf.udf3',
		[udf4] VARCHAR(MAX)		'$.udf.udf4',
		[udf5] VARCHAR(MAX)		'$.udf.udf5',
		[udf6] VARCHAR(MAX)		'$.udf.udf6',
		[udf7] VARCHAR(MAX)		'$.udf.udf7',
		[udf8] VARCHAR(MAX)		'$.udf.udf8',
		[udf9] VARCHAR(MAX)		'$.udf.udf9',
		[udf10] VARCHAR(MAX)	'$.udf.udf10',
		[udf11] VARCHAR(MAX)	'$.udf.udf11',
		[udf12] VARCHAR(MAX)	'$.udf.udf12',
		[udf13] VARCHAR(MAX)	'$.udf.udf13',
		[udf14] VARCHAR(MAX)	'$.udf.udf14',
		[udf15] VARCHAR(MAX)	'$.udf.udf15',
		[udf16] VARCHAR(MAX)	'$.udf.udf16',
		[udf17] VARCHAR(MAX)	'$.udf.udf17',
		[udf18] VARCHAR(MAX)	'$.udf.udf18',
		[udf19] VARCHAR(MAX)	'$.udf.udf19',
		[udf20] VARCHAR(MAX)	'$.udf.udf20',
		[udf21] VARCHAR(MAX)	'$.udf.udf21',
		[udf22] VARCHAR(MAX)	'$.udf.udf22',
		[udf23] VARCHAR(MAX)	'$.udf.udf23',
		[udf24] VARCHAR(MAX)	'$.udf.udf24',
		[udf25] VARCHAR(MAX)	'$.udf.udf25',
		[udf26] VARCHAR(MAX)	'$.udf.udf26',
		[udf27] VARCHAR(MAX)	'$.udf.udf27',
		[udf28] VARCHAR(MAX)	'$.udf.udf28',
		[udf29] VARCHAR(MAX)	'$.udf.udf29',
		[udf30] VARCHAR(MAX)	'$.udf.udf30'
	 );
GO

IF OBJECT_ID ('drmm.mergeUdfs') IS NOT NULL
    DROP PROCEDURE drmm.mergeUdfs
GO

CREATE PROCEDURE drmm.mergeUdfs
AS

	MERGE drmm.udfs AS target
	USING temp.udfs AS source 
	ON (target.[timestamp] = source.[timestamp])
	WHEN MATCHED THEN 
		UPDATE SET 
			target.[deviceId] = source.[deviceId],
			target.[udf1] = source.[udf1],
			target.[udf2] = source.[udf2],
			target.[udf3] = source.[udf3],
			target.[udf4] = source.[udf4],
			target.[udf5] = source.[udf5],
			target.[udf6] = source.[udf6],
			target.[udf7] = source.[udf7],
			target.[udf8] = source.[udf8],
			target.[udf9] = source.[udf9],
			target.[udf10] = source.[udf10],
			target.[udf11] = source.[udf11],
			target.[udf12] = source.[udf12],
			target.[udf13] = source.[udf13],
			target.[udf14] = source.[udf14],
			target.[udf15] = source.[udf15],
			target.[udf16] = source.[udf16],
			target.[udf17] = source.[udf17],
			target.[udf18] = source.[udf18],
			target.[udf19] = source.[udf19],
			target.[udf20] = source.[udf20],
			target.[udf21] = source.[udf21],
			target.[udf22] = source.[udf22],
			target.[udf23] = source.[udf23],
			target.[udf24] = source.[udf24],
			target.[udf25] = source.[udf25],
			target.[udf26] = source.[udf26],
			target.[udf27] = source.[udf27],
			target.[udf28] = source.[udf28],
			target.[udf29] = source.[udf29],
			target.[udf30] = source.[udf30],
			target.[timestamp] = source.[timestamp]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[deviceId],
			[udf1],
			[udf2],
			[udf3],
			[udf4],
			[udf5],
			[udf6],
			[udf7],
			[udf8],
			[udf9],
			[udf10],
			[udf11],
			[udf12],
			[udf13],
			[udf14],
			[udf15],
			[udf16],
			[udf17],
			[udf18],
			[udf19],
			[udf20],
			[udf21],
			[udf22],
			[udf23],
			[udf24],
			[udf25],
			[udf26],
			[udf27],
			[udf28],
			[udf29],
			[udf30],
			[timestamp] 
		)
		VALUES (
			source.[deviceId],
			source.[udf1],
			source.[udf2],
			source.[udf3],
			source.[udf4],
			source.[udf5],
			source.[udf6],
			source.[udf7],
			source.[udf8],
			source.[udf9],
			source.[udf10],
			source.[udf11],
			source.[udf12],
			source.[udf13],
			source.[udf14],
			source.[udf15],
			source.[udf16],
			source.[udf17],
			source.[udf18],
			source.[udf19],
			source.[udf20],
			source.[udf21],
			source.[udf22],
			source.[udf23],
			source.[udf24],
			source.[udf25],
			source.[udf26],
			source.[udf27],
			source.[udf28],
			source.[udf29],
			source.[udf30],
			source.[timestamp] 
		);

GO