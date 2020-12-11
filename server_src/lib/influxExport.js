//Support for influx v1.X

const Influx = require("influx");
const settingsClean = require("../lib/dataFunctions/settingsClean.js");
const SettingsClean = settingsClean.SettingsClean;

let db = null;

async function databaseSetup() {
  let serverSettings = await SettingsClean.returnSystemSettings();
  if (typeof clientSettings === "undefined") {
    await SettingsClean.start();
    serverSettings = await SettingsClean.returnSystemSettings();
  }
  if (
    typeof serverSettings.influxExport !== "undefined" &&
    serverSettings.influxExport.active
  ) {
    console.log("Active... setup database...");

    let options = {
      username: serverSettings.influxExport.username,
      password: serverSettings.influxExport.password,
      host: serverSettings.influxExport.host,
      port: serverSettings.influxExport.port,
      database: serverSettings.influxExport.database,
    };

    db = new Influx.InfluxDB(options);
    // eslint-disable-next-line no-use-before-define
    await checkDatabase(options);
    // eslint-disable-next-line no-use-before-define
    //await updateRetention();
    return "Setup";
  } else {
    console.log("No settings or disabled for influxdb export");
  }
}
async function checkDatabase(options) {
  const names = await db.getDatabaseNames();
  if (!names.includes(options.database)) {
    console.log(
      "Cannot find database... creating new database: " + options.database
    );
    await db.createDatabase(options.database);
    return "database created...";
  } else {
    console.log("Database found!");
    return "database exists... skipping";
  }
}
async function updateRetention() {
  const retention = await db.alterRetentionPolicy(octofarm, {
    duration: retentionPolicy.duation,
    replication: retentionPolicy.replication,
    default: retentionPolicy.default,
  });
  return "BLA";
}
function writePoints(tags, measurement, dataPoints) {
  db.writePoints([
    {
      measurement: measurement,
      tags: tags,
      fields: dataPoints,
    },
  ]).catch((err) => {
    console.error(`Error saving data to InfluxDB! ${err.stack}`);
  });
}

module.exports = { databaseSetup, checkDatabase, writePoints };