/**
 * @description Backing service for the AgentscriptUI prototype.
 * The `complete_validation` Agent Script action renders a countdown timer via a
 * Custom Lightning Type (CLT) editor bound to the `confirmation` input, then
 * returns the full answer once the user validates after the security delay.
 *
 * Inner class ValidationInput is the CLT data shape referenced by
 * lightningTypes/validationTimer/schema.json.
 */
public with sharing class ValidationService {
    /**
     * @description CLT input shape — referenced by validationTimer/schema.json.
     * `confirmationToken` stays blank while the timer counts down and is set to
     * "CONFIRMED" by the LWC once the delay elapses, so the platform Submit
     * button can be gated on a non-empty required value.
     */
    public class ValidationInput {
        @InvocableVariable(
            label='Confirmation Token'
            description='Set to CONFIRMED by the timer LWC once the delay elapses'
            required=true
        )
        public String confirmationToken;
    }

    /**
     * @description Invocable request wrapper — field name must match the
     * Agent Script action input name (`confirmation`).
     */
    public class ValidationRequest {
        @InvocableVariable(required=true)
        public ValidationInput confirmation;
    }

    /**
     * @description Invocable response wrapper — field name must match the
     * Agent Script action output name (`answer`).
     */
    public class ValidationResponse {
        @InvocableVariable
        public String answer;
    }

    /**
     * @description Returns the full answer after the security delay validation.
     * Mock implementation (no DML) — safe for demo purposes.
     * @param requests List of ValidationRequest objects
     * @return List of ValidationResponse objects with the full answer
     */
    @InvocableMethod(
        label='Complete Validation'
        description='Returns the full answer after the security delay'
    )
    public static List<ValidationResponse> completeValidation(
        List<ValidationRequest> requests
    ) {
        List<ValidationResponse> responses = new List<ValidationResponse>();
        for (ValidationRequest req : requests) {
            String reference =
                'VAL-' +
                String.valueOf(Math.round(Math.random() * 900000 + 100000));
            ValidationResponse res = new ValidationResponse();
            res.answer =
                'Opération validée ✅. La demande a été contrôlée puis approuvée ' +
                'après le délai de sécurité réglementaire de 30 secondes. ' +
                'Référence de validation : ' +
                reference +
                '. Aucune action supplémentaire n\'est requise de votre part.';
            responses.add(res);
        }
        return responses;
    }
}
