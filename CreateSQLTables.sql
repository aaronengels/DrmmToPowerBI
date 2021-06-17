IF SCHEMA_ID('drmm') IS NULL
BEGIN
	EXEC('CREATE SCHEMA [drmm]')
END
GO

IF OBJECT_ID ('drmm.sites') IS NULL
CREATE TABLE [drmm].[sites](
	[id] INT NOT NULL PRIMARY KEY,
	[uid] CHAR(36),
	[name] VARCHAR(MAX),
	[description] VARCHAR(MAX),
	[ondemand] BIT,
	[deleted] BIT,
	[autotaskName] VARCHAR(MAX),
	[autotaskId] INT,
	[portalUrl] VARCHAR(MAX),
	[lastUpdate] DATETIME
)
GO

IF OBJECT_ID ('drmm.devices') IS NULL
CREATE TABLE [drmm].[devices](
	[id] INT NOT NULL PRIMARY KEY,
	[uid] CHAR(36),
	[siteId] INT,
	[name] VARCHAR(MAX),
	[description] VARCHAR(MAX),
	[deviceType] VARCHAR(MAX),
	[deviceClass] VARCHAR(MAX),
	[manufacturer] VARCHAR(MAX),
	[model] VARCHAR(MAX),
	[serialnumber] VARCHAR(MAX),
	[cpuCores] INT,
	[memory] INT,
	[domain] VARCHAR(MAX),
	[is64bit] BIT,
	[snmpEnabled] BIT,
	[suspended] BIT,
	[deleted] BIT,
	[warrantyDate] DATETIME,
	[lastUpdate] DATETIME
)
GO

IF OBJECT_ID ('drmm.devices_timevary') IS NULL
CREATE TABLE [drmm].[devices_timevary](
	[id] INT,
	[dotNetVersion] VARCHAR(MAX),
	[username] VARCHAR(MAX),
	[lastSeenUser] VARCHAR(MAX),
	[ipaddress] VARCHAR(MAX),
	[os] VARCHAR(MAX),
	[rebootRequired] BIT,
	[lastAudit] DATETIME,
	[lastReboot] DATETIME,
	[lastSeen] DATETIME,
	[lastUpdate] DATETIME
)
GO

IF OBJECT_ID('drmm.FK_devices_site') IS NULL
ALTER TABLE [drmm].[devices] WITH CHECK ADD CONSTRAINT [FK_devices_site] FOREIGN KEY([siteId]) REFERENCES [drmm].[sites] ([id])
GO

IF OBJECT_ID ('drmm.patchstatus') IS NULL
CREATE TABLE [drmm].[patchstatus](
	[deviceId] INT,
	[status] VARCHAR(MAX),
	[notApproved] VARCHAR(MAX),
	[approvedPending] VARCHAR(MAX),
	[installed] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO

IF OBJECT_ID('drmm.FK_patchstatus_device') IS NULL
ALTER TABLE [drmm].[patchstatus] ADD CONSTRAINT [FK_patchstatus_device] FOREIGN KEY([deviceId]) REFERENCES [drmm].[devices] ([id])
GO

IF OBJECT_ID ('drmm.avstatus') IS NULL
CREATE TABLE [drmm].[avstatus](
	[deviceId] INT,
	[product] VARCHAR(MAX),
	[status] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO

IF OBJECT_ID('drmm.FK_avstatus_device') IS NULL
ALTER TABLE [drmm].[avstatus] ADD CONSTRAINT [FK_avstatus_device] FOREIGN KEY([deviceId]) REFERENCES [drmm].[devices] ([id])
GO


IF OBJECT_ID ('drmm.thirdpartystatus') IS NULL
CREATE TABLE [drmm].[thirdpartystatus](
	[deviceId] INT,
	[status] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO

IF OBJECT_ID('FK_thirdpartystatus_device') IS NULL
ALTER TABLE [drmm].[thirdpartystatus] ADD CONSTRAINT [FK_thirdpartystatus_device] FOREIGN KEY([deviceId]) REFERENCES [drmm].[devices] ([id])
GO

IF OBJECT_ID ('drmm.agentstatus') IS NULL
CREATE TABLE [drmm].[agentstatus](
	[deviceId] INT,
	[online] BIT,
	[timestamp] DATETIME
)
GO

IF OBJECT_ID('FK_agentstatus_device') IS NULL
ALTER TABLE [drmm].[agentstatus] ADD CONSTRAINT [FK_agentstatus_device] FOREIGN KEY([deviceId]) REFERENCES [drmm].[devices] ([id])
GO

IF OBJECT_ID ('drmm.diskstatus') IS NULL
CREATE TABLE [drmm].[diskstatus](
	[deviceId] INT,
	[description] VARCHAR(MAX),
	[identifier] VARCHAR(MAX),
	[size] INT,
	[freespace] INT,
	[timestamp] DATETIME
)

IF OBJECT_ID('FK_diskstatus_device') IS NULL
ALTER TABLE [drmm].[diskstatus] ADD CONSTRAINT [FK_diskstatus_device] FOREIGN KEY([deviceId]) REFERENCES [drmm].[devices] ([id])
GO

IF OBJECT_ID ('drmm.alerts') IS NULL
CREATE TABLE [drmm].[alerts](
	[uid] CHAR(36) NOT NULL PRIMARY KEY,
	[deviceId] INT,
	[type] VARCHAR(MAX),
	[message] VARCHAR(MAX),
	[diagnostic] VARCHAR(MAX),
	[priority] VARCHAR(MAX),
	[ticketId] VARCHAR(MAX),
	[muted] BIT,
	[resolved] BIT,
	[resolvedBy] VARCHAR(MAX),
	[resolvedOn] DATETIME,
	[timestamp] DATETIME
)
GO

IF OBJECT_ID('FK_alerts_device') IS NULL
ALTER TABLE [drmm].[alerts] ADD CONSTRAINT [FK_alerts_device] FOREIGN KEY([deviceId]) REFERENCES [drmm].[devices] ([id])
GO

IF OBJECT_ID ('drmm.udfs') IS NULL
CREATE TABLE [drmm].[udfs](
	[deviceId] INT,
	[udf1] VARCHAR(MAX),
	[udf2] VARCHAR(MAX),
	[udf3] VARCHAR(MAX),
	[udf4] VARCHAR(MAX),
	[udf5] VARCHAR(MAX),
	[udf6] VARCHAR(MAX),
	[udf7] VARCHAR(MAX),
	[udf8] VARCHAR(MAX),
	[udf9] VARCHAR(MAX),
	[udf10] VARCHAR(MAX),
	[udf11] VARCHAR(MAX),
	[udf12] VARCHAR(MAX),
	[udf13] VARCHAR(MAX),
	[udf14] VARCHAR(MAX),
	[udf15] VARCHAR(MAX),
	[udf16] VARCHAR(MAX),
	[udf17] VARCHAR(MAX),
	[udf18] VARCHAR(MAX),
	[udf19] VARCHAR(MAX),
	[udf20] VARCHAR(MAX),
	[udf21] VARCHAR(MAX),
	[udf22] VARCHAR(MAX),
	[udf23] VARCHAR(MAX),
	[udf24] VARCHAR(MAX),
	[udf25] VARCHAR(MAX),
	[udf26] VARCHAR(MAX),
	[udf27] VARCHAR(MAX),
	[udf28] VARCHAR(MAX),
	[udf29] VARCHAR(MAX),
	[udf30] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO

IF OBJECT_ID('FK_udfs_device') IS NULL
ALTER TABLE [drmm].[udfs] ADD CONSTRAINT [FK_udfs_device] FOREIGN KEY([deviceId]) REFERENCES [drmm].[devices] ([id])
GO

IF SCHEMA_ID('temp') IS NULL
BEGIN
	EXEC('CREATE SCHEMA [temp]')
END
GO

IF OBJECT_ID ('temp.sites') IS NULL
CREATE TABLE [temp].[sites](
	[id] INT NOT NULL PRIMARY KEY,
	[uid] CHAR(36),
	[name] VARCHAR(MAX),
	[description] VARCHAR(MAX),
	[ondemand] BIT,
	[deleted] BIT,
	[autotaskName] VARCHAR(MAX),
	[autotaskId] INT,
	[portalUrl] VARCHAR(MAX),
	[lastUpdate] DATETIME
)
GO

IF OBJECT_ID ('temp.devices') IS NULL
CREATE TABLE [temp].[devices](
	[id] INT NOT NULL PRIMARY KEY,
	[uid] CHAR(36),
	[siteId] INT,
	[name] VARCHAR(MAX),
	[description] VARCHAR(MAX),
	[deviceType] VARCHAR(MAX),
	[deviceClass] VARCHAR(MAX),
	[manufacturer] VARCHAR(MAX),
	[model] VARCHAR(MAX),
	[serialnumber] VARCHAR(MAX),
	[cpuCores] INT,
	[memory] INT,
	[domain] VARCHAR(MAX),
	[is64bit] BIT,
	[snmpEnabled] BIT,
	[suspended] BIT,
	[deleted] BIT,
	[warrantyDate] DATETIME,
	[lastUpdate] DATETIME
)

GO

IF OBJECT_ID ('temp.devices_timevary') IS NULL
CREATE TABLE [temp].[devices_timevary](
	[id] INT,
	[dotNetVersion] VARCHAR(MAX),
	[username] VARCHAR(MAX),
	[lastSeenUser] VARCHAR(MAX),
	[ipaddress] VARCHAR(MAX),
	[os] VARCHAR(MAX),
	[rebootRequired] BIT,
	[lastAudit] DATETIME,
	[lastReboot] DATETIME,
	[lastSeen] DATETIME,
	[lastUpdate] DATETIME
)

GO

IF OBJECT_ID ('temp.alerts') IS NULL
CREATE TABLE [temp].[alerts](
	[uid] CHAR(36) NOT NULL PRIMARY KEY,
	[deviceId] INT,
	[type] VARCHAR(MAX),
	[message] VARCHAR(MAX),
	[diagnostic] VARCHAR(MAX),
	[priority] VARCHAR(MAX),
	[ticketId] VARCHAR(MAX),
	[muted] BIT,
	[resolved] BIT,
	[resolvedBy] VARCHAR(MAX),
	[resolvedOn] DATETIME,
	[timestamp] DATETIME
)
GO

IF OBJECT_ID ('temp.patchstatus') IS NULL
CREATE TABLE [temp].[patchstatus](
	[deviceId] INT NOT NULL PRIMARY KEY,
	[status] VARCHAR(MAX),
	[notApproved] VARCHAR(MAX),
	[approvedPending] VARCHAR(MAX),
	[installed] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO

IF OBJECT_ID ('temp.avstatus') IS NULL
CREATE TABLE [temp].[avstatus](
	[deviceId] INT NOT NULL PRIMARY KEY,
	[product] VARCHAR(MAX),
	[status] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO

IF OBJECT_ID ('temp.thirdpartystatus') IS NULL
CREATE TABLE [temp].[thirdpartystatus](
	[deviceId] INT NOT NULL PRIMARY KEY,
	[status] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO

IF OBJECT_ID ('temp.agentstatus') IS NULL
CREATE TABLE [temp].[agentstatus](
	[deviceId] INT NOT NULL PRIMARY KEY,
	[online] BIT,
	[timestamp] DATETIME
)
GO

IF OBJECT_ID ('temp.diskstatus') IS NULL
CREATE TABLE [temp].[diskstatus](
	[deviceId] INT,
	[description] VARCHAR(MAX),
	[identifier] VARCHAR(MAX),
	[size] INT,
	[freespace] INT,
	[timestamp] DATETIME
)

IF OBJECT_ID ('temp.udfs') IS NULL
CREATE TABLE [temp].[udfs](
	[deviceId] INT NOT NULL PRIMARY KEY,
	[udf1] VARCHAR(MAX),
	[udf2] VARCHAR(MAX),
	[udf3] VARCHAR(MAX),
	[udf4] VARCHAR(MAX),
	[udf5] VARCHAR(MAX),
	[udf6] VARCHAR(MAX),
	[udf7] VARCHAR(MAX),
	[udf8] VARCHAR(MAX),
	[udf9] VARCHAR(MAX),
	[udf10] VARCHAR(MAX),
	[udf11] VARCHAR(MAX),
	[udf12] VARCHAR(MAX),
	[udf13] VARCHAR(MAX),
	[udf14] VARCHAR(MAX),
	[udf15] VARCHAR(MAX),
	[udf16] VARCHAR(MAX),
	[udf17] VARCHAR(MAX),
	[udf18] VARCHAR(MAX),
	[udf19] VARCHAR(MAX),
	[udf20] VARCHAR(MAX),
	[udf21] VARCHAR(MAX),
	[udf22] VARCHAR(MAX),
	[udf23] VARCHAR(MAX),
	[udf24] VARCHAR(MAX),
	[udf25] VARCHAR(MAX),
	[udf26] VARCHAR(MAX),
	[udf27] VARCHAR(MAX),
	[udf28] VARCHAR(MAX),
	[udf29] VARCHAR(MAX),
	[udf30] VARCHAR(MAX),
	[timestamp] DATETIME
)
GO