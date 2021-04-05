import admin from "firebase-admin";
import * as functions from "firebase-functions";

interface FlybisMinimumPostDuration {
  minimumPostDuration: Number;
  timestamp: admin.firestore.Timestamp;
}

export async function cspReport(
  request: functions.https.Request,
  response: functions.Response
) {
  const report = JSON.parse(request.body.toString("utf8"));

  if (report) {
    report.timestamp = admin.firestore.Timestamp.now();

    admin
      .firestore()
      .collection("cspreports")
      .add(report)
      .then((doc) => {
        const result = `CSP Report with ID: ${doc.id} has been added.`;

        console.log(result, doc);

        return response.send({
          result,
        });
      })
      .catch((error) => {
        const result = "Failed to add CSP Report.";

        console.error(result, error);

        return response.status(500).send({
          result,
        });
      });
  } else {
    const result = "Without Body";

    console.log(result);

    response.status(400).send({
      result,
    });
  }
}

export async function setMinimumPostDuration() {
  admin
    .firestore()
    .collection("flybis")
    .doc("public")
    .collection("minimumPostDurations")
    .doc()
    .set({
      minimumPostDuration: Math.floor(
        (Math.random() * (24 - 12) + 12) * 60 * 60 * 1000
      ),
      timestamp: admin.firestore.Timestamp.now(),
    } as FlybisMinimumPostDuration)
    .then((doc) => {
      const result = "Minimum Post Duration updated";

      console.log(result, doc);
    })
    .catch((error) => {
      const result = "Error on update Minimum Post Duration";

      console.error(result, error);
    });
}
